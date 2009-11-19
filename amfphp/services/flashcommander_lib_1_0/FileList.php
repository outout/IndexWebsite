<?php

require_once "script/reccopy.php";

class FileList {
	
	/**************************** FILE OPERATIONS ***************************
	 *   
	 * 	You can use the $permission array to enable file operations.
	 * 	IMPORTANT: make sure you add authentication/authorization code
	 * 	if you enable any of the operations
	 *
	 ************************************************************************/
	
	var $permissions = array("delete"=>true, "copy"=>true, "rename"=>true, "makedir"=>true);
	
 	function getFileList ( $dir_name ){
 		
 		if (!is_dir($dir_name))
 			return array(
					"valid"=>0,
					"error"=>"Directory not found!", 
					"code"=>"dirnotfound");
 		
		$dir = dir( $dir_name );
		$file_list = array();
		while(false !== ($file = $dir->read()))
		{
			$filename = $dir_name.'/'.$file;
		
			if ( $file == '.'  ) { continue; }
			
			else if ($file == '..')
			{
				$type = 1;
				array_push( $file_list,  array( 'type'=>$type, 'name' => $file, 'ext' =>'' , 'basename'=>$file, 'size' => '', 'date'=>'', 'perm'=>'' ));
			}
			else if ( is_dir($filename) )
			{
				$type = 2;
				$date = filemtime($filename);
				$perm = base_convert(fileperms($filename),10,8);
 				$perm = substr( $perm, strlen( $perm )-3, strlen($perm));
				array_push( $file_list,  array('type'=>$type, 'name' => $file, 'ext' =>'', 'basename'=>$file,'size' => '', 'date'=>$date, 'perm'=>$perm ));
			}
			else if ( is_file($filename) )
			{
				$type = 3;
				$date = filemtime($filename);
				$perm = base_convert(fileperms($filename),10,8);
 				$perm = substr( $perm, strlen( $perm )-3, strlen($perm));
				$size = sprintf("%u", filesize($filename));
				$name = $file;
				$nameArr = $this->_splitFilename($file);
				$basename = $nameArr[0];
				$ext = $nameArr[1];
				array_push( $file_list,  array('type'=>$type, 'name' => $name, 'ext' => $ext, 'basename'=>$basename, 'size' => $size, 'date'=>$date, 'perm'=>$perm ));
			}
		}
		$dir->close();
		//
		$path = $dir_name;
		$result = array( "valid"=>1, "path"=>$path, "list"=>$file_list);
		return $result;
   } 	
   
   function deleteFiles ( $file_list, $source_dir ){
 		if (!$this->permissions["delete"]) 
 			return array("valid"=>0, "error"=>"You don't have permission to delete files!");

		foreach( $file_list as $file ){
			$source_file = $source_dir.'/'.$file['name'];
			if (is_file( $source_file ))
			{ 
				unlink( $source_file) ;
			}
			else if (is_dir( $source_file )){
				recdelete( $source_file );
			};
		}
	 	$result = $this->getFileList( $source_dir );
	 	$resultObj = array( "valid" =>1, "path"=>$result["path"], "list"=>$result["list"] );
	 	return $resultObj;
 	}
	
 	function overwriteCheck ( $file_list, $source_dir, $target_dir){
		//	
		$ovcount = 0;
		foreach( $file_list as $item )
	 	{
	 		$source_file = $source_dir.'/'.$item['name'];
	 		$target_file = $target_dir.'/'.$item['newname'];
	 		//
			if ($source_file == substr($target_file, 0, strlen($source_file))){
				$resultObj = array( 
								"valid" => 0,
								"error" => "You can't copy a directory to itself!'",
								"code" => "copytoitself"
								);
				return $resultObj;
			};	
			//
			$ovcount += checkoverwrite($source_file, $target_file);
	 	}
		if ($ovcount>0){
			return array(
				"valid" => 0, 
				"error" => "You are going to overwrite " . $ovcount . " files. \n Do you want to proceed?",
				"count" => $ovcount,
				"code" => "overwrite");
		}
		else {
			return array(
				"valid"=>1, 
				"list"=>$file_list, 
				"sourcedir"=>$source_dir, 
				"targetdir"=>$target_dir);
		}
 	}
	
 	function copyFiles ( $file_list, $source_dir, $target_dir, $move = false ){
 		
 		if (!$this->permissions["copy"]) 
 			return array("valid"=>0, "error"=>"You don't have permission to copy files!");
		
		foreach( $file_list as $item )
	 	{
	 		
	 		$source_file = $source_dir.'/'.$item['name'];
	 		$target_file = $target_dir.'/'.$item['newname'];
	 		//
			if ($source_file == substr($target_file, 0, strlen($source_file))){
				$resultObj = array( 
								"valid" => 0,
								"error" => "You can't copy a directory to itself!'",
								"code"=> "copytoitself"
								);
				return $resultObj;
			};	
			//
	 		if ($move) { reccopy( $source_file, $target_file, true ); }
	 		else { reccopy( $source_file, $target_file, false ); }
	 	}

	 	
	 	$sourcelist = $this->getFileList( $source_dir );
	 	$targetlist = $this->getFileList( $target_dir );
	 	$resultObj = array( "valid" => 1 , "sourcelist" => $sourcelist, "targetlist" => $targetlist);
	 	return $resultObj;
 	}
 	
	function makeDir ( $dir_name ){
 		if (!$this->permissions["makedir"]) 
 			return array("valid"=>0, "error"=>"You don't have permission to make directories!");
 		
		if ( is_dir($dir_name)){
			$resultObj = array( 
							"valid" => 0,
							"error" => "Directory already exists!",
							"code" => "direxists"
							);
			return $resultObj;
		}
		//
		if (mkdir( $dir_name )){
			chmod( $dir_name, 0777 );
			$dirParts = explode('/', $dir_name);
			array_pop($dirParts);
			$parentdir = implode('/', $dirParts);
			$filelist = $this->getFileList( $parentdir );
	 		$resultObj = array( "valid" => 1, "list" => $filelist["list"], "path"=>$filelist["path"]);
	 		return $resultObj;		
		}
		else {
 			return array(
						"valid"=>0, 
						"error" => "There was an error renaming the file!",
						"code" => "errorrenaming"
						);
		}
			
 	}

 	function rename( $source_dir, $old_name, $new_name ){
		if (!$this->permissions["rename"]) 
 			return array("valid"=>0, "error"=>"You don't have permission to rename files!");
		
		$oldname = $source_dir.'/'.$old_name;
		$newname = $source_dir.'/'.$new_name;
		
 		if (is_file( $newname ) || is_dir( $newname )){
			$resultObj = array( 
							"valid" => 0,
							"error" => "Target file already exists!",
							"code" => "targetexists"
							);
			return $resultObj;
 		}
 		//
 		if (is_file( $oldname ) || is_dir( $oldname ))
 		{
 			if (rename( $oldname, $newname )){
			 	$result = $this->getFileList( $source_dir );
			 	return array( "valid" =>1, "path"=>$result["path"], "list"=>$result["list"] );
 			}
 			else {
 				return array(
							"valid"=>0, 
							"error" => "There was an error renaming the file!",
							"code" => "errorrenaming"
							);
 			}
 		}
 	}

	function _splitFilename($filename)
	{
	    $pos = strrpos($filename, '.');
	    if ($pos === false){ 
	        return array($filename, ''); // no extension
	    }
	    else if ($pos === 0){
	        return array($filename, ''); // .htaccess
	    }
	    else {
	        $basename = substr($filename, 0, $pos);
	        $extension = substr($filename, $pos+1);
	        return array($basename, $extension);
	    }
	}  	
 	
}

?>
