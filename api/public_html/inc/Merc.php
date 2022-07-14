<?
require_once('Entity.php');
class Merc extends Entity implements JsonSerializable {
	protected static $Field_Names = array( 'id', 'name', 'bossname', 'commander_id', 'unit_id', 'nrunits' );
	protected static $Table_Name = 'mercs';
}
?>
