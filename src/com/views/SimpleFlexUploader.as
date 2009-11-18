import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.URLRequest;

import mx.controls.Alert;
import mx.events.ListEvent;
 
// ----------------------------------------
//  Private Constants
// ----------------------------------------
 
/**
 * @constant
 * @private
 * @default 5242880
 * @property Maximum upload size in bytes.
 * ( 5242880 bytes = 5 megabytes )
 */
private const _MAX_FILE_SIZE:Number = 5242880;
 
// ----------------------------------------
//  Bindable Private Variables
// ----------------------------------------
 
/**
 * @bindable
 * @public
 * @property List of the descriptions of the file types the user
 * can choose from. The content of this list will be displayed
 * in the "fileTypesList" List component.
 */
[Bindable]
private var _fileTypesDescription:Array;
 
/**
 * @bindable
 * @public
 * @property List of the file the user is going to upload.
 * It essentially holds the "name" and "size" properties of the selected file.
 */
[Bindable]
private var _fileToUpload:Array;
 
// ----------------------------------------
//  Private Variables
// ----------------------------------------
 
/**
 * @private
 * @property Holds a reference to the file the user selects
 */
private var _selectedFile:FileReference;
 
/**
 * @private
 * @property Will let the user browser his system for files. 
 */
private var _fileReference:FileReference;
 
/**
 * @private
 * @property List of the possible file types that the
 * user can choose from before uploading a file. 
 */
private var _fileTypesArray:Array;
 
/**
 * @private
 * @property Reference to the fiter that the user selects
 * when clicking on one of the filters from the "fileTypesList" List.
 */
private var _selectedFilter:FileFilter;
 
/**
 * @private
 * @property The path to the PHP script that will do the uploading.
 */
private var _uploadScript:String = "http://localhost/index-debug/assets/php/upload.php";
 
/**
 * Our FileFilter objects.
 */
private var _imageFilter:FileFilter = new FileFilter("Images", "*.jpg; *.jpeg; *.gif; *.png");
private var _textFilter:FileFilter = new FileFilter("Text Files", "*.txt; *.rtf; *.doc");
private var _packedFilter:FileFilter = new FileFilter("Packed Files", "*.zip; *.rar");
private var _soundFilter:FileFilter = new FileFilter("Sound Files", "*.mp3");
 
// ----------------------------------------
//  Private Methods
// ----------------------------------------
 
/**
 * @private
 * Is triggered once the application is initialized.
 */
private function initializeApplication():void
{
    // Update the arrays that hold references to our FileFilter objects and
    // to the descriptions of these FileFilter objects.
    _fileTypesArray = new Array(_imageFilter, _textFilter, _packedFilter, _soundFilter);
    _fileTypesDescription = new Array(_imageFilter.description, _textFilter.description, 
                                      _packedFilter.description, _soundFilter.description);
}
 
/**
 * @private
 * Is triggered once the user selects a filter from the filters list. It stores the
 * selected filter for later use and it modifies it's description to make it easier
 * to read for the human eye.
 */
private function onFileTypeSelect(event:ListEvent):void
{    
    _selectedFilter = FileFilter(_fileTypesArray[event.rowIndex]);
 
    var pattern:RegExp = /;/g;
    var parenthesisPattern:RegExp = /\(/g;
    var extension:String = _selectedFilter.extension;
    
    // Check for a possible left parenthesis; if it exists then the filter
    // has already been updated and we should leave it as it is.
    if(_selectedFilter.description.search(parenthesisPattern) == -1)
        _selectedFilter.description += " ( " + extension.replace(pattern, ",") + " )";
}
 
/**
 * @private
 * Is triggered once the user clicks the "Browse" button. It first checks to see if
 * the user has selected a filter, if he didn't, then it throws and Alert, but if
 * he did select a filter then we create a FileReference object and let the
 * user browse his system for certain files ( the ones allowed by the filter
 * he has selected previously ).
 */
private function browseForFile(event:MouseEvent):void
{
    if (_selectedFilter != null)
    {
        _fileReference = new FileReference();
        _fileReference.addEventListener(Event.SELECT, onFileSelected);
        _fileReference.browse([_selectedFilter]);
    }
    else
    {
        Alert.show("Please select a file type from the provided list.", 
                   "ERROR! File type not selected!");
    }
}
 
/**
 * @private
 * Is triggered once the user selects a file for upload. We check if the selected
 * file exceeds the maximum size limit, if it exceeds it then we throw an Alert
 * but if it does not exceed the maximum size limit then we save it's properties
 * and save a referecen to the selected file.
 */
private function onFileSelected(event:Event):void
{
    var selectedFile:FileReference = FileReference(event.target);
 
    if (selectedFile.size > _MAX_FILE_SIZE)
    {
        Alert.show("Sorry but the selected file exceeds the 5MB size limit.\n" + 
              "Please try uploading a different file.", "ERROR! Maximum File Size Exceeded!");
    }
    else
    {
        // Convert the file size from Bytes into Megabytes
        var fileSize:String = String(selectedFile.size * 9.53674316 * Math.pow(10, -7));
        fileSize = fileSize.slice(0, 4) + " MB";
 
        // Create and object the hold the file's properties
        var file:Object = {name: selectedFile.name, size: fileSize};
 
        _fileToUpload = new Array();
        _fileToUpload.push(file);
        _selectedFile = selectedFile;
 
        this.uploadBtn.enabled = true;
    }
}
 
/**
 * @private
 * Is triggered once the user clicks the "Upload" button. We disable both the "Browse"
 * and "Upload" buttons so that the user can't mess around while the file is being
 * uploaded and obviously.
 */
private function uploadFileToServer(event:MouseEvent):void
{
    this.browseBtn.enabled = false;
    this.uploadBtn.enabled = false;
    this.uploadProgressBar.visible = true;
 
    var request:URLRequest = new URLRequest(_uploadScript);
    var fileToUpload:FileReference = FileReference(_selectedFile);
    fileToUpload.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
    fileToUpload.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
    fileToUpload.addEventListener(Event.COMPLETE, onUploadComplete);
    fileToUpload.upload(request);
}
 
/**
 * @private
 * Is triggred if an Intput-Output Error occurs.
 */
private function onIOError(event:IOErrorEvent):void
{
    Alert.show(String(event.text), "Input-Output ERROR Occurred!");
 
    // Enabled our buttons.
    this.browseBtn.enabled = true;
    this.uploadBtn.enabled = true;
    // Reset the progress bar.
    this.uploadProgressBar.visible = false;
    this.uploadProgressBar.setProgress(0, 100);
}
 
/**
 * @private
 * Updates our ProgressBar so that the user can know how much
 * of the file has been uploaded to our server.
 */
private function onUploadProgress(event:ProgressEvent):void
{
    // Calculate the precent loaded and update the ProgressBar.
    var progress:Number = (100 * (event.bytesLoaded / event.bytesTotal)) >> 0;
    this.uploadProgressBar.label = progress + "% - " + "Uploading file..."
    this.uploadProgressBar.setProgress(progress, 100);
}
 
/**
 * @private
 * Is triggered once the file has successfully been uploaded. We throw an Alert,
 * signaling that the upload process has ended successfully, we reset the
 * "_fileToUpload" list and we hide the ProgressBar.
 */
private function onUploadComplete(event:Event):void
{
    Alert.show(String(_fileToUpload[0].name) + " has been uploaded successfully.",
                      "File has been uploaded successfully.");
 
    _fileToUpload = null;
    this.browseBtn.enabled = true;
    this.uploadBtn.enabled = false;
    this.uploadProgressBar.visible = false;
    this.uploadProgressBar.setProgress(0, 100);
    this.uploadProgressBar.label = "0% - Uploading file..."
}