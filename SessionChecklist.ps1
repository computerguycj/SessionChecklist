Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Session Checklist"
    Width="300"
    SizeToContent="Height"
    Topmost="True"
    WindowStyle="ToolWindow"
    ResizeMode="NoResize"
    Background="#1A1A1A"
    FontFamily="Segoe UI">

    <Window.Resources>

        <!-- CheckBox Style -->
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#D4D4D4"/>
            <Setter Property="FontSize" Value="12.5"/>
            <Setter Property="Padding" Value="6,0,0,0"/>
            <Setter Property="Margin" Value="0,0,0,0"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Style.Triggers>
                <Trigger Property="IsChecked" Value="True">
                    <Setter Property="Foreground" Value="#555"/>
                    <Setter Property="TextBlock.TextDecorations" Value="Strikethrough"/>
                </Trigger>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Foreground" Value="#FFFFFF"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- Row Border Style -->
        <Style x:Key="RowStyle" TargetType="Border">
            <Setter Property="Padding" Value="14,10"/>
            <Setter Property="BorderThickness" Value="0,0,0,1"/>
            <Setter Property="BorderBrush" Value="#2A2A2A"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#222222"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- Reset Button Style -->
        <Style x:Key="ResetBtn" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#555"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Padding" Value="0"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Foreground" Value="#888"/>
                </Trigger>
            </Style.Triggers>
        </Style>

    </Window.Resources>

    <StackPanel>

        <!-- Header -->
        <Border Background="#141414" Padding="14,10">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <Ellipse Width="7" Height="7" Fill="#4EC9B0" Margin="0,0,8,0" VerticalAlignment="Center"/>
                    <TextBlock Text="AI  SESSION" Foreground="#888" FontSize="10" FontWeight="SemiBold"
                               VerticalAlignment="Center"/>
                </StackPanel>
                <Button x:Name="BtnReset" Grid.Column="1" Style="{StaticResource ResetBtn}"
                        Content="reset" ToolTip="Uncheck all items" Margin="0,0,12,0"/>
                <Button x:Name="BtnCollapse" Grid.Column="2" Style="{StaticResource ResetBtn}"
                        Content="hide" ToolTip="Collapse"/>
            </Grid>
        </Border>

        <!-- Collapsible content -->
        <StackPanel x:Name="CollapsibleContent">

        <!-- Start of Session -->
        <Border Style="{StaticResource RowStyle}">
            <StackPanel>
                <CheckBox x:Name="ChkStart" Content="Start of session"/>
                <TextBlock TextWrapping="Wrap" Foreground="#666" FontSize="11"
                           Margin="22,4,0,0">
                    Before opening a chat, spend 30 seconds asking: what is the one thing I'm trying to accomplish? That answer determines which files get @mentioned - usually an interface, a DTO, and one concrete class - not a project folder.
                </TextBlock>
            </StackPanel>
        </Border>

        <!-- During the Session -->
        <Border Style="{StaticResource RowStyle}">
            <StackPanel>
                <CheckBox x:Name="ChkDuring" Content="During the session"/>
                <TextBlock TextWrapping="Wrap" Foreground="#666" FontSize="11"
                           Margin="22,4,0,0">
                    When the AI starts saying "based on what you've told me earlier..." or begins repeating itself, the context window is getting noisy. Don't wait until it breaks - do a handover proactively.
                </TextBlock>
            </StackPanel>
        </Border>

        <!-- End of Session -->
        <Border Style="{StaticResource RowStyle}" BorderThickness="0">
            <StackPanel>
                <CheckBox x:Name="ChkEnd" Content="End of session"/>
                <TextBlock TextWrapping="Wrap" Foreground="#666" FontSize="11"
                           Margin="22,4,0,0">
                    Ask the AI to summarize what was decided and what's unresolved. Paste that into your CONTEXT.md and commit it. Two minutes now saves reconstructing mental state tomorrow.
                </TextBlock>
            </StackPanel>
        </Border>

        <!-- Footer: progress indicator -->
        <Border Background="#141414" Padding="14,8">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <ProgressBar x:Name="ProgressBar" Height="3" Minimum="0" Maximum="3"
                             Value="0" Background="#2A2A2A" Foreground="#4EC9B0"
                             VerticalAlignment="Center" BorderThickness="0"/>
                <TextBlock x:Name="ProgressLabel" Grid.Column="1" Foreground="#444"
                           FontSize="10" Margin="10,0,0,0" VerticalAlignment="Center"
                           Text="0 / 3"/>
            </Grid>
        </Border>

        </StackPanel><!-- end CollapsibleContent -->

    </StackPanel>
</Window>
"@

# Build the window
$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get controls
$chkStart         = $window.FindName("ChkStart")
$chkDuring        = $window.FindName("ChkDuring")
$chkEnd           = $window.FindName("ChkEnd")
$btnReset         = $window.FindName("BtnReset")
$btnCollapse      = $window.FindName("BtnCollapse")
$collapsible      = $window.FindName("CollapsibleContent")
$progress         = $window.FindName("ProgressBar")
$progLabel        = $window.FindName("ProgressLabel")

# Update progress bar whenever a checkbox changes
$updateProgress = {
    $count = 0
    if ($chkStart.IsChecked)  { $count++ }
    if ($chkDuring.IsChecked) { $count++ }
    if ($chkEnd.IsChecked)    { $count++ }
    $progress.Value  = $count
    $progLabel.Text  = "$count / 3"

    if ($count -eq 3) {
        $progress.Foreground = [Windows.Media.Brushes]::MediumSeaGreen
    } else {
        $progress.Foreground = [Windows.Media.SolidColorBrush]::new(
            [Windows.Media.ColorConverter]::ConvertFromString("#4EC9B0")
        )
    }
}

$chkStart.Add_Checked($updateProgress)
$chkStart.Add_Unchecked($updateProgress)
$chkDuring.Add_Checked($updateProgress)
$chkDuring.Add_Unchecked($updateProgress)
$chkEnd.Add_Checked($updateProgress)
$chkEnd.Add_Unchecked($updateProgress)

# Reset button
$btnReset.Add_Click({
    $chkStart.IsChecked  = $false
    $chkDuring.IsChecked = $false
    $chkEnd.IsChecked    = $false
})

# Collapse / expand toggle
$btnCollapse.Add_Click({
    if ($collapsible.Visibility -eq [System.Windows.Visibility]::Visible) {
        $collapsible.Visibility = [System.Windows.Visibility]::Collapsed
        $btnCollapse.Content    = "show"
        $btnCollapse.ToolTip    = "Expand"
    } else {
        $collapsible.Visibility = [System.Windows.Visibility]::Visible
        $btnCollapse.Content    = "hide"
        $btnCollapse.ToolTip    = "Collapse"
    }
})

$window.ShowDialog() | Out-Null
