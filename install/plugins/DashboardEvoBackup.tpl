/**
 * DashboardEvoBackup
 *
 * Dashboard EvoBackup widget for Evolution CMS
 * @author    Nicola Lambathakis
 * @category    plugin
 * @version    1 beta
 * @license	   http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnManagerWelcomeHome
 * @internal    @installset base
 * @internal    @modx_category Dashboard
 * @author      Nicola Lambathakis http://www.tattoocms.it/
 * @documentation Requirements: This plugin requires Evolution 1.4 or later
 * @reportissues 
 * @link        
 * @lastupdate  23/10/2017
 * @internal    @properties &wdgVisibility=Show widget for:;menu;All,AdminOnly,AdminExcluded,ThisRoleOnly,ThisUserOnly;All &ThisRole=Run only for this role:;string;;;(role id) &ThisUser=Run only for this user:;string;;;(username) &wdgTitle= Widget Title:;string;Evo Backup  &wdgicon= widget icon:;string;fa-download  &wdgposition=widget position:;list;1,2,3,4,5,6,7,8,9,10;1 &wdgsizex=widget width:;list;12,6,4,3;12  &showArchiveBkp=Show Archive Backup:;menu;yes,no;yes &ArchiveBackup= Archive Backup dir;;_evobackup_archives;(evobackup folder) &DaysAlert= Alert when backups are older than (days);;7;(days)
 */
// get manager role
$internalKey = $modx->getLoginUserID();
$sid = $modx->sid;
$role = $_SESSION['mgrRole'];
$user = $_SESSION['mgrShortname'];
// show widget only to Admin role 1
if(($role!=1) AND ($wdgVisibility == 'AdminOnly')) {}
// show widget to all manager users excluded Admin role 1
else if(($role==1) AND ($wdgVisibility == 'AdminExcluded')) {}
// show widget only to "this" role id
else if(($role!=$ThisRole) AND ($wdgVisibility == 'ThisRoleOnly')) {}
// show widget only to "this" username
else if(($user!=$ThisUser) AND ($wdgVisibility == 'ThisUserOnly')) {}
else {
// get language
global $modx,$_lang;
// get plugin id
$result = $modx->db->select('id', $this->getFullTableName("site_plugins"), "name='{$modx->event->activePlugin}' AND disabled=0");
$pluginid = $modx->db->getValue($result);
if($modx->hasPermission('edit_plugin')) {
$button_pl_config = '<a data-toggle="tooltip" href="javascript:;" title="' . $_lang["settings_config"] . '" class="text-muted pull-right" onclick="parent.modx.popup({url:\''. MODX_MANAGER_URL.'?a=102&id='.$pluginid.'&tab=1\',title1:\'' . $_lang["settings_config"] . '\',icon:\'fa-cog\',iframe:\'iframe\',selector2:\'#tabConfig\',position:\'center center\',width:\'80%\',height:\'80%\',wrap:\'evo-tab-page-home\',hide:0,hover:0,overlay:1,overlayclose:1})" ><i class="fa fa-cog"></i> </a>';
}
$modx->setPlaceholder('button_pl_config', $button_pl_config);
//days
$days = $DaysAlert; 
$now = new \DateTime();
//get latest database backup
$path = $modx->config['base_path'] . 'assets/backup/';
if (file_exists($path)) {
$latest_ctime = 0;
$latest_filename = '';    
$d = dir($path);
while (false !== ($entry = $d->read())) {
$filepath = "{$path}/{$entry}";
//Check whether the entry is a file etc.:
    if(is_file($filepath) && filectime($filepath) > $latest_ctime) {
    $latest_ctime = filemtime($filepath);
    $latest_filename = $entry;
    }//end if is file etc.
}//end while going over files in dir.
$filetime =  date("Y-m-d-Hi", filectime($filepath));
if (filectime($filepath) < ( time() - ( $days * 24 * 60 * 60 ) ) ) {
$msg = "<span class=\"text-danger pull-right\"><i class=\"fa fa-exclamation-triangle\"></i> This backup is older than $days day(s)</span>";
}
}
//get latest archives backup
$zpath = $_SERVER['DOCUMENT_ROOT'].$ArchiveBackup;
//$zpath = "_evobackup_archives"; 
if (file_exists($zpath)) {
$zlatest_ctime = 0;
$zlatest_filename = '';    
$zd = dir($zpath);
while (false !== ($zentry = $zd->read())) {
$zfilepath = "{$zpath}/{$zentry}";
//Check whether the entry is a file etc.:
    if(is_file($zfilepath) && filectime($zfilepath) > $zlatest_ctime) {
    $zlatest_ctime = filemtime($zfilepath);
    $zlatest_filename = $zentry;
    }//end if is file etc.
}//end while going over files in dir.
$zfiletime =  date("Y-m-d-Hi", fileatime($zfilepath));
if (filectime($zfilepath) < ( time() - ( $days * 24 * 60 * 60 ) ) ) {
$zmsg = "<span class=\"text-danger pull-right\"><i class=\"fa fa-exclamation-triangle\"></i> This backup is older than $days day(s)</span>";
}
}

if ($showArchiveBkp == 'yes'){
$ArchiveBkp ="<tr>
<td><i class=\"fa fa-download text-muted\"></i> <b>Last Files backup</b>: $zlatest_filename</td><td>$zfiletime  $zmsg</td><td style=\"text-align: right;\" class=\"actions\"><a title=\"".$_lang['download_backup']."\" target=\"_blank\" href=\"".$modx->config['site_url']."assets/modules/evobackup/download.php?filename=$zlatest_filename\"><i class=\"fa fa-download\"></i></a></td>
</tr>";
}
	else {
$ArchiveBkp == '';
	}
		//end if showArchiveBkp
	
$wdgout = "
<div class=\"table-responsive\">
<table class=\"table data\">
<thead>
<tr>
<th><b>".$_lang['files_filename']."</b></th>
<th><b>".$_lang['date']."</b></th>
<th style=\"text-align:right;\"><b>".$_lang['download']."</b></th>
</tr>
</thead>
<tbody>
	<tr>
<td><i class=\"fa fa-database text-muted\"></i> <b>Last DataBase backup</b>: $latest_filename</td><td>$filetime  $msg</td><td style=\"text-align: right;\" class=\"actions\"><a title=\"".$_lang['download']."\" target=\"_blank\" href=\"".$modx->config['site_url']."assets/modules/evobackup/downloadsql.php?filename=$latest_filename\"><i class=\"fa fa-download\"></i></a></td>
</tr>
$ArchiveBkp
</tbody>
</table>
</div>";
$e = &$modx->Event;
switch($e->name){
case 'OnManagerWelcomeHome':
			$widgets['DashboardEvoBackup'] = array(
				'menuindex' =>''.$wdgposition.'',
				'id' => 'DashboardEvoBackup'.$pluginid.'',
				'cols' => 'col-md-'.$wdgsizex.'',
				'icon' => ''.$wdgicon.'',
				'title' => ''.$wdgTitle.' '.$button_pl_config.'',
				'body' => '<div class="widget-stage">'.$wdgout.'</div>'
			);	
            $e->output(serialize($widgets));
    break;
}
}