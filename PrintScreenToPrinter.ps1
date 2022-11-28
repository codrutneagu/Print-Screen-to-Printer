#Made by Codrut Neagu
Add-type -AssemblyName System.Drawing

function Test-KeyPress
{

    <#
        .SYNOPSIS
        Checks to see if a key or keys are currently pressed.

        .DESCRIPTION
        Checks to see if a key or keys are currently pressed. If all specified keys are pressed then will return true, but if 
        any of the specified keys are not pressed, false will be returned.

        .PARAMETER Keys
        Specifies the key(s) to check for. These must be of type "System.Windows.Forms.Keys"

        .EXAMPLE
        Test-KeyPress -Keys ControlKey

        Check to see if the Ctrl key is pressed

        .EXAMPLE
        Test-KeyPress -Keys ControlKey,Shift

        Test if Ctrl and Shift are pressed simultaneously (a chord)

        .LINK
        Uses the Windows API method GetAsyncKeyState to test for keypresses
        http://www.pinvoke.net/default.aspx/user32.GetAsyncKeyState

        The above method accepts values of type "system.windows.forms.keys"
        https://msdn.microsoft.com/en-us/library/system.windows.forms.keys(v=vs.110).aspx

        .LINK
        http://powershell.com/cs/blogs/tips/archive/2015/12/08/detecting-key-presses-across-applications.aspx

        .INPUTS
        System.Windows.Forms.Keys

        .OUTPUTS
        System.Boolean
    #>
            
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Windows.Forms.Keys[]]
        $Keys
    )
    
    # use the User32 API to define a keypress datatype
    $Signature = @'
    [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
    public static extern short GetAsyncKeyState(int virtualKeyCode); 
'@
    $API = Add-Type -MemberDefinition $Signature -Name 'Keypress' -Namespace Keytest -PassThru
    
    # test if each key in the collection is pressed
    $Result = foreach ($Key in $Keys)
    {
        [bool]($API::GetAsyncKeyState($Key) -eq -32767)
    }
    
    # if all are pressed, return true, if any are not pressed, return false
    $Result -notcontains $false
}

[System.Windows.Forms.MessageBox]::Show("Press the PRINT SCREEN key to capture a screenshot and send it directly to the PRINTER. Press the PAUSE / BREAK key to stop." , "PrintScreenToPrinter by digitalcitizen.life")

    $stop = $false
    while (-not $stop) {

      # If Escape key is pressed exit script
      $stop = Test-KeyPress -Keys Pause
      if ($stop) {
        [System.Windows.Forms.MessageBox]::Show("Stopped sending screenshots directly to the printer." , "PrintScreenToPrinter by digitalcitizen.life")
      }

      # Test if PrintScreen is pressed
      $isDown =  Test-KeyPress -Keys PrintScreen
      Write-Output ($isDown)
      if ($isDown)
      {
        # Take fullscreen screenshot and save it in C:\Users\User\AppData\Local\Temp
        $File = "$env:TEMP\ScreenCapture.png"

        $Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
        $bitmap = New-Object System.Drawing.Bitmap $Screen.Width, $Screen.Height
        $graphic = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphic.CopyFromScreen(0, 0, 0, 0, $bitmap.Size)

        $bitmap.Save($File)

        # Print to default printer
        Start-Process -FilePath $File -Verb Print
    
      }

      # Wait and listen for keypress
      Start-Sleep -milliseconds 50
  
    }