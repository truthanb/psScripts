#Place the desired filepath in the $up.prepare command, the output is the library file id which you can then place in the relevant field via debugger.
$up = $services.library.CreateUploadInfo($screen.AuthenticationKey, 0)
$up.Prepare('/*filepath*/', '')
$saved = $services.library.UploadFile($screen.AuthenticationKey, $up)
$saved.File[0].Id