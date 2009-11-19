<?php
/*
 * Created on 2007.01.06.
 */
 
 function reccopy($srcdir, $dstdir, $move = false) {
  $num = 0;
  //
  if (is_file($srcdir)) {
  	copy($srcdir, $dstdir);
  	if ($move) unlink($srcdir);
  	$num++;
  	return $num;
  }
  //
  if(!is_dir($dstdir)) mkdir($dstdir);
  if($curdir = opendir($srcdir)) {
   while($file = readdir($curdir)) {
     if($file != '.' && $file != '..') {
       $srcfile = $srcdir . '/' . $file;
       $dstfile = $dstdir . '/' . $file;
       if(is_file($srcfile)) {
           copy($srcfile, $dstfile);
           if ($move) unlink($srcfile );
           $num++;
       }
       else if(is_dir($srcfile)) {
         $num += reccopy($srcfile, $dstfile, $move );
       }
     }
   }
   closedir($curdir);
   if ($move) rmdir($srcdir);
  }
  return $num;
}

function checkoverwrite($srcdir, $dstdir){
	
  if (!isset($num)) $num = 0;
  //
  if (is_file($srcdir) && is_file($dstdir)) {
  	$num++;
  	return $num;
  }
  //
  if(is_dir($srcdir) && $curdir = opendir($srcdir)) {
   while($file = readdir($curdir)) {
     if($file != '.' && $file != '..') {
       $srcfile = $srcdir . '/' . $file;
       $dstfile = $dstdir . '/' . $file;
       if(is_file($srcfile) && is_file($dstfile)) {
           $num++;
       }
       else if(is_dir($srcfile)) {
         $num += checkoverwrite($srcfile, $dstfile);
       }
     }
   }
   closedir($curdir);
  }
  return $num;	
}

 function recdelete($srcdir) {
  //
  if($curdir = opendir($srcdir)) {
   while($file = readdir($curdir)) {
     if($file != '.' && $file != '..') {
       $srcfile = $srcdir . '/' . $file;
       if(is_file($srcfile)) { unlink($srcfile ); }
       else if(is_dir($srcfile)) { $num += recdelete($srcfile); }
     }
   }
   closedir($curdir);
   rmdir($srcdir);
  }
  return $num;
}

?>
