resource "null_resource" "PowerShellScriptRunAlways" {

    triggers = {
        trigger = "${uuid()}"
    }

  provisioner "local-exec" {
    command = ".'${path.module}\\ps\\Get-Processes.ps1' -First 10 > processes.txt"
    interpreter = ["PowerShell", "-Command"]
  }
}