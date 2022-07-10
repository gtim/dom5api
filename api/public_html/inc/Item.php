<?

require_once('Entity.php');

class Item extends Entity implements JsonSerializable {

	protected static $Field_Names = array( 'id', 'name', 'type', 'constlevel', 'mainlevel', 'mpath', 'gemcost' );
	protected static $Table_Name = 'items';

}

?>
