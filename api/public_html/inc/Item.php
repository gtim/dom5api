<?

class Item implements JsonSerializable {

	/*
	 * Constructors
	 */

	public function __construct(
		public string $id,
		public string $name
	) {
	}

	# from_id
	#
	# Constructs item from id
	# return: Item, or null if no matching ID
	public static function from_id( int $id ) {
		$db = new SQLite3( 'data/items.db' );
		$stmt = $db->prepare( 'SELECT id, name FROM items WHERE id=:id' );
		$stmt->bindValue( ':id', $id, SQLITE3_INTEGER );
		$result = $stmt->execute();
		if ( $row = $result->fetchArray() ) {
			$item = new Item( id: $row['id'], name: $row['name'] );
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
		$stmt = $db->prepare( 'SELECT id, name FROM items WHERE name=:name' );
		$stmt->bindValue( ':name', $name, SQLITE3_TEXT );
		$result = $stmt->execute();
		$items = array();
		while ( $row = $result->fetchArray() ) {
			array_push( $items, new Item( id: $row['id'], name: $row['name'] ) );
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
		$stmt = $db->prepare( 'SELECT id, name FROM items' );
		$result = $stmt->execute();
		$max_similarity = -1e6;
		$rows_at_max = array();
		while ( $row = $result->fetchArray() ) {
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
			function($row){ return new Item( id: $row['id'], name: $row['name'] ); },
			$rows_at_max
		);
		return $items;
	}

	/*
	 * Getters
	 */

	public function get_screenshot_url() {
		return sprintf( '/items/%d/screenshot', $this->id );
	}


	/*
	 * JSON 
	 *
	 * Custom JSON serialization into the object presented to API consumers
	 */

	public function jsonSerialize(): array {
		return [
			'id' => $this->id,
			'name' => $this->name,
			'screenshot' => $this->get_screenshot_url()
		];
	}

}

?>
