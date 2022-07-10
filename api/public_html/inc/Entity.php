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
		$needle = strtoupper($name);
		$db = new SQLite3( 'data/'.static::$Table_Name.'.db' );
		$stmt = $db->prepare( 'SELECT '.implode(',',static::$Field_Names).' FROM '.static::$Table_Name );
		$result = $stmt->execute();
		$max_similarity = -1e6;
		$rows_at_max = array();
		while ( $row = $result->fetchArray(SQLITE3_ASSOC) ) {
			# Finding a proper "similar-text" measure is not straight-forward.
			# Pull-requests for better alternatives are welcome.
			$similarity = -round( levenshtein( $needle, strtoupper($row['name']), 1, 100, 100 ) / 5 );
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

