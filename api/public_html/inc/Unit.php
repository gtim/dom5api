<?

require_once('Entity.php');

class Unit extends Entity implements JsonSerializable {

	protected static $Field_Names = array( 'id', 'name', 'hp', 'size' );
	protected static $Table_Name = 'units';
	protected static $Properties_Table_Name = 'unit_props';

	public function __construct(
		public array  $props
	) {
		if ( array_key_exists( 'randompaths', $this->props ) ) {
			$this->props['randompaths'] = array_map( 'json_decode', $this->props['randompaths'] );
		}
	}

}

?>
