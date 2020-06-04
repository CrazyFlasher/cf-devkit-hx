var path = FLfile.platformPathToURI("$dirPath");
var taskId = "$taskId";

try {
    if (taskId == "export") {
        var files = FLfile.listFolder(path + "/*.fla", "files");
        for (file in files) {
            var curFile = files[file];
            if (curFile.indexOf("RECOVER_") == -1)
            {
            	fl.openDocument(path + "/" + curFile);
				fl.getDocumentDOM().publish();
				//fl.closeDocument(fl.getDocumentDOM());
            }
        }
    }
    // fl.closeDocument(doc, false);
    // fl.quit(false);
    saveOutput();
} catch (e) {
    fl.trace(e);
    saveOutput();
}

function saveOutput()
{
    fl.outputPanel.save(path + "/tempfile");
}