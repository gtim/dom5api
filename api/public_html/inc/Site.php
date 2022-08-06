<?
require_once('Entity.php');
class Site extends Entity implements JsonSerializable {
	protected static $Field_Names = array( 'id', 'name', 'path', 'level', 'rarity');
	protected static $Table_Name = 'sites';
	protected static $Properties_Table_Name = 'site_props';

	public function __construct(
		public array  $props
	) {
		$excluded_props = array(
			'F','A','W','E','S','D','N','B', # remove gem counts
			'loc' # location mask -- should be human-readable
		);
		foreach ( $excluded_props as $excluded_prop ) {
			unset($this->props[$excluded_prop]);
		}
	}
}
?>
