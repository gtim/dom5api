<?

require_once('Entity.php');

class Spell extends Entity implements JsonSerializable {

	protected static $Field_Names = array( 'id', 'name', 'gemcost', 'mpath', 'type', 'school', 'researchlevel' );
	protected static $Table_Name = 'spells';

}

?>
