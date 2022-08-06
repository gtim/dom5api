<?

require_once('Unit.php');

class Commander extends Unit implements JsonSerializable {

	protected static $Table_Name = 'commanders';
	protected static $Properties_Table_Name = 'commander_props';

}

?>
