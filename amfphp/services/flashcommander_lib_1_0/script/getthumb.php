<?php
header("Content-type: image/jpeg") ;
//header("Content-Disposition: attachment; filename=image_name.jpg");

$thumbsize=50;

$filename = $_GET['image'];
$thumbsize = isset($_GET['size']) ? $_GET['size'] : $thumbsize;

list($width, $height) = getimagesize($filename);

$imgratio=$width/$height;

if ($imgratio>1)
{
	$newwidth = $thumbsize;
	$newheight = $thumbsize/$imgratio;
}
else
{
	$newheight = $thumbsize;
	$newwidth = $thumbsize*$imgratio;
}

$parts = pathinfo($filename);
$ext = strtolower($parts['extension']);

$target = imagecreatetruecolor($newwidth,$newheight);
if ($ext =='png'){
	imagealphablending($target, false);
	imagesavealpha($target, true);
}

if ($ext=='jpg' || $ext=='jpeg'){
	$source = imagecreatefromjpeg($filename);
}
else if ($ext=='png'){
	$source = imagecreatefrompng($filename);
}
else if ($ext=='gif'){
	$source = imagecreatefromgif($filename);
}

imagecopyresampled($target, $source, 0, 0, 0, 0, $newwidth, $newheight, $width , $height );

if ($ext=='jpg' || $ext=='jpeg'){
	imagejpeg($target, "", 70);
}
else if ($ext=='png'){
	imagepng($target);
} 
else if ($ext=='gif'){
	imagegif($target);
} 


imagedestroy( $target );
imagedestroy( $source );

?>