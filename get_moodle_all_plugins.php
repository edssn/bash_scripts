<?php
define('CLI_SCRIPT', 1);
require(__DIR__.'/config.php');

$plugins_dir = array(
    "mod"=>"mod","antivirus"=>"lib/antivirus","assignsubmission"=>"mod/assign/submission","assignfeedback"=>"mod/assign/feedback","booktool"=>"mod/book/tool","customfield"=>"customfield/field",
    "datafield"=>"mod/data/field","datapreset"=>"mod/data/preset","ltisource"=>"mod/lti/source","fileconverter"=>"files/converter","ltiservice"=>"mod/lti/service","mlbackend"=>"lib/mlbackend",
    "forumreport"=>"mod/forum/report","quiz"=>"mod/quiz/report","quizaccess"=>"mod/quiz/accessrule","scormreport"=>"mod/scorm/report","workshopform"=>"mod/workshop/form","workshopallocation"=>"mod/workshop/allocation",
    "workshopeval"=>"mod/workshop/eval","block"=>"blocks","qtype"=>"question/type","qbehaviour"=>"question/behaviour","qformat"=>"question/format","filter"=>"filter",
    "editor"=>"lib/editor","atto"=>"lib/editor/atto/plugins","tinymce"=>"lib/editor/tinymce/plugins","enrol"=>"enrol","auth"=>"auth","tool"=>"admin/tool",
    "logstore"=>"admin/tool/log/store","availability"=>"availability/condition","calendartype"=>"calendar/type","message"=>"message/output","format"=>"course/format","dataformat"=>"dataformat",
    "profilefield"=>"user/profile/field","report"=>"report","coursereport"=>"course/report","gradeexport"=>"grade/export","gradeimport"=>"grade/import","gradereport"=>"grade/report",
    "gradingform"=>"grade/grading/form","mnetservice"=>"mnet/service","webservice"=>"webservice","repository"=>"repository","portfolio"=>"portfolio","search"=>"search/engine",
    "media"=>"media/player","plagiarism"=>"plagiarism","cachestore"=>"cache/stores","cachelock"=>"cache/locks","theme"=>"theme","local"=>"local",
    "assignment"=>"mod/assignment/type","contenttype"=>"contentbank/contenttype","h5plib"=>"h5p/h5plib","qbank"=>"question/bank"
);

$pm = \core_plugin_manager::instance();
$types = $pm->get_plugin_types();

$external_plugins = array();

foreach ($types as $t => $path) {
    $plugins = $pm->get_installed_plugins($t);
    $standard_plugins = $pm->standard_plugins_list($t);
    $standard_plugins = is_array($standard_plugins) ? array_flip($standard_plugins) : array();
    $plugin_dir = isset($plugins_dir[$t]) ? $plugins_dir[$t] : "";
    echo "\n";
    echo "\n$t\n################\n";
    foreach ($plugins as $p => $version) {
        $s = isset($standard_plugins[$p]) ? "true" : "false";
        echo "$p ($version) - (Standard?: $s) - ($plugin_dir/$p)\n";


				if (!isset($standard_plugins[$p]) && !empty($plugin_dir)) {
			    array_push($external_plugins, "$p ($version) - (Standard?: $s) - ($plugin_dir/$p)");
				}
    }
}

echo "\n\nThird Party Plugins\n";
var_dump($external_plugins);
