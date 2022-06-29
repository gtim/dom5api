<?

class Item implements JsonSerializable {

	// SQLite field names, identical to those used in dom5inspector
	private static $Field_Names = array( 'id', 'name', 'type', 'constlevel', 'mainlevel', 'mpath', 'gemcost' );

	/*
	 * Constructors
	 */

	public function __construct(
		public array  $props
	) {
	}

	# from_id
	#
	# Constructs item from id
	# return: Item, or null if no matching ID
	public static function from_id( int $id ) {
		$db = new SQLite3( 'data/items.db' );
		$stmt = $db->prepare( 'SELECT '.implode(',',Item::$Field_Names).' FROM items WHERE id=:id' );
		$stmt->bindValue( ':id', $id, SQLITE3_INTEGER );
		$result = $stmt->execute();
		if ( $row = $result->fetchArray(SQLITE3_ASSOC) ) {
			$item = new Item( props: $row );
		} else {
			$item = null;
		}
		$db->close();
		return $item;
	}
	
	# items_with_name
	#
	# Constructs list of items with name
	# return: array of Items (empty array if no match)
	public static function items_with_name( string $name ) :array {
		$db = new SQLite3( 'data/items.db' );
		$stmt = $db->prepare( 'SELECT '.implode(',',Item::$Field_Names).' FROM items WHERE name=:name' );
		$stmt->bindValue( ':name', $name, SQLITE3_TEXT );
		$result = $stmt->execute();
		$items = array();
		while ( $row = $result->fetchArray(SQLITE3_ASSOC) ) {
			array_push( $items, new Item( props: $row ) );
		}
		$db->close();
		return $items;
	}

	# items_with_similar name
	#
	# Constructs list of items with similar name, using fuzzy string matching
	# return: array of Items. Contains the best match, or multiple matches if tied
	public static function items_with_similar_name( string $name, &$max_similarity ) :array {
		$needle = strtoupper($name);
		$db = new SQLite3( 'data/items.db' );
		$stmt = $db->prepare( 'SELECT '.implode(',',Item::$Field_Names).' FROM items' );
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
		$items = array_map(
			function($row){ return new Item( props: $row ); },
			$rows_at_max
		);
		return $items;
	}


	/*
	 * Getters
	 */

	public function id() {
		return $this->props['id'];
	}

	public function get_screenshot_url() {
		return sprintf( '/items/%d/screenshot', $this->id() );
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
