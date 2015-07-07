<?php
setcookie('user_id', -1, time() - 3600 * 10, '/');
?>
<html><script>history.go(-1);</script></html>
