Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class User32 {
        [DllImport("user32.dll")]
        public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern uint GetTickCount();
    }
    [StructLayout(LayoutKind.Explicit)]
    public struct INPUT {
        [FieldOffset(0)]
        public int type;
        [FieldOffset(4)]
        public MOUSEINPUT mi;
    }
    public struct MOUSEINPUT {
        public int dx;
        public int dy;
        public uint mouseData;
        public uint dwFlags;
        public uint time;
        public IntPtr dwExtraInfo;
    }
"@

$iterations = 100
$delayMs = 10

$input = New-Object INPUT
$input.type = 0  
$input.mi.dx = 0
$input.mi.dy = 0
$input.mi.mouseData = 0
$input.mi.dwFlags = 0x0002  
$input.mi.time = 0
$input.mi.dwExtraInfo = [System.IntPtr]::Zero

$latencies = New-Object System.Collections.ArrayList
for ($i = 0; $i -lt $iterations; $i++) {
    $startTime = [User32]::GetTickCount()
    [User32]::SendInput(1, $input, [System.Runtime.InteropServices.Marshal]::SizeOf($input))
    $endTime = [User32]::GetTickCount()
    $latency = $endTime - $startTime
    $latencies.Add($latency) | Out-Null
    Start-Sleep -Milliseconds $delayMs
}

$averageLatency = $latencies | Measure-Object -Average | Select-Object -ExpandProperty Average
$minLatency = $latencies | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
$maxLatency = $latencies | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
Write-Host "Average input latency: $($averageLatency) ms"
Write-Host "Minimum input latency: $($minLatency) ms"
Write-Host "Maximum input latency: $($maxLatency) ms"
