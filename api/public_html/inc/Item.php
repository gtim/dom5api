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
