Init-Tridion

$session = new-object Tridion.ContentManager.Session
$getNewObjectMI = [Tridion.ContentManager.Session].GetMethod("GetNewObject")
add-member -InputObject $session -MemberType ScriptMethod -Name "GetNewUser" -Value {
  [Tridion.ContentManager.Session].GetMethod(
  "GetNewObject").MakeGenericMethod([Tridion.ContentManager.Security.User]).Invoke($this, @())
}
return $session