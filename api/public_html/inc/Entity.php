<?

abstract class Entity implements JsonSerializable {

	// SQLite field names, identical to those used in dom5inspector
	protected static $Field_Names;
	// SQLite table name
	//   AND sqlite db filename ("items" in items.db)
	//   AND base endpoint url for screenshots ("items" in /items/:id/screenshot)
	protected static $Table_Name;

	/*
	 * Constructors
	 */

	public function __construct(
		public array  $props
	) {
	}

	protected static function construct_entity( array $props ) {
	}

	# from_id
	#
	# Constructs entity from id
	# return: Entity, or null if no matching ID
	public static function from_id( int $id ) {
		$db = new SQLite3( 'data/'.static::$Table_Name.'.db' );
		$stmt = $db->prepare( 'SELECT '.implode(',',static::$Field_Names).' FROM '.static::$Table_Name.' WHERE id=:id' );
		$stmt->bindValue( ':id', $id, SQLITE3_INTEGER );
		$result = $stmt->execute();
		if ( $row = $result->fetchArray(SQLITE3_ASSOC) ) {
			$entity = new static( props: $row );
		} else {
			$entity = null;
		}
		$db->close();
		return $entity;
	}
	
	# entities_with_name
	#
	# Constructs list of entities with name
	# return: array of Entities (empty array if no match)
	public static function entities_with_name( string $name ) :array {
		$db = new SQLite3( 'data/'.static::$Table_Name.'.db' );
		$stmt = $db->prepare( 'SELECT '.implode(',',static::$Field_Names).' FROM '.static::$Table_Name.' WHERE name=:name' );
		$stmt->bindValue( ':name', $name, SQLITE3_TEXT );
		$result = $stmt->execute();
		$entities = array();
		while ( $row = $result->fetchArray(SQLITE3_ASSOC) ) {
			array_push( $entities, new static( props: $row ) );
		}
		$db->close();
		return $entities;
	}

	# entities_with_similar name
	#
	# Constructs list of entities with similar name, using fuzzy string matching
	# return: array of Entities. Contains the best match, or multiple matches if tied
	public static function entities_with_similar_name( string $name, &$max_similarity ) :array {
		$needle = static::name_similarity_preprocess($name);
		$db = new SQLite3( 'data/'.static::$Table_Name.'.db' );
		$stmt = $db->prepare( 'SELECT '.implode(',',static::$Field_Names).' FROM '.static::$Table_Name );
		$result = $stmt->execute();
		$max_similarity = -1e6;
		$rows_at_max = array();
		while ( $row = $result->fetchArray(SQLITE3_ASSOC) ) {
			$similarity = static::name_similarity( $needle, static::name_similarity_preprocess($row['name']) );
			if ( $similarity > $max_similarity ) {
				$max_similarity = $similarity;
				$rows_at_max = array( $row );
			} elseif ( $similarity == $max_similarity ) {
				array_push( $rows_at_max, $row );
			}
		}
		$db->close();
		$entities = array_map(
			function($row){ return new static( props: $row ); },
			$rows_at_max
		);
		return $entities;
	}
	private static function name_similarity_preprocess( string $name) {
		return str_replace( array("'",','), '',
			strtoupper($name)
		);
	}
	private static function name_similarity( string $needle, string $entry ) {
		# Finding a proper "similar-text" measure is not straight-forward.
		# Pull-requests for better alternatives are welcome.
		# Test cases can be found in t/19_fuzzy_match_tests.t.
		#
		# Current ad-hoc algorithm:
		# 1. check for complete match (entity name equals needle)
		# 2. check for partial match if needle is long enough (entity name contains needle)
		# 3. check for levenshtein distance 1 to any "word" in the entry
		# 4. levenshtein magic

		# 1. Exact match
		if ( $needle == $entry ) {
			return 1e6;
		}

		# 2. Partial match
		if ( strlen($needle) >= 3 && strpos( $entry, $needle ) !== false ) {
			return 1e4;
		}

		# 3. Levenshtein closeness to any word in entry
		foreach ( explode(' ',$entry) as $word ) {
			if ( levenshtein( $needle, $word ) <= 1 ) {
				return 100;
			}
		}

		# 4. Levenshtein: almost-free insertion
		#return -levenshtein( $needle, $entry, 1, 10, 10 );
		return -round( levenshtein( $needle, $entry, 1, 100, 100 ) / 5 );
	}


	/*
	 * Getters
	 */

	public function id() {
		return $this->props['id'];
	}

	public function get_screenshot_url() {
		return sprintf( '/'.static::$Table_Name.'/%d/screenshot', $this->id() );
	}


	/*
	 * JSON 
	 *
	 * Custom JSON serialization into the object presented to API consumers
	 */

	public function jsonSerialize(): array {
		return array_merge(
			$this->props,
			[ 'screenshot' => $this->get_screenshot_url() ]
		);
	}

}

?>

