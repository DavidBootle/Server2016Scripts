$subdirectories = @(
    "Desktop"
    "Documents",
    "Downloads",
    "Music",
    "Pictures",
    "Saved Games",
    "Videos"
)

Get-ChildItem -Directory -Path "C:\Users" | ForEach-Object -Process {
    
    $name = $_.Name

    echo "$($name):"

    $subdirectories | ForEach-Object -Process {


        $folderpath = "C:\Users\$($name)\$($_)"

        $folder = $_



        try {
            if ( (Get-ChildItem $folderpath -ErrorAction Stop | Measure-Object).Count -ne 0) {
                echo "$($folder) is not empty"
            }
        } catch {
            echo "$($folder) could not be accessed"
        }
    }

    echo ""
}