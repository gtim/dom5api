<?

require_once('Entity.php');

class Commander extends Entity implements JsonSerializable {

	protected static $Field_Names = array( 'id', 'name', 'hp', 'size' );
	protected static $Table_Name = 'commanders';

}

?>

