<?
require_once('Entity.php');
class Site extends Entity implements JsonSerializable {
	protected static $Field_Names = array( 'id', 'name', 'path', 'level', 'rarity');
	protected static $Table_Name = 'sites';
}
?>
