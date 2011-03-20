package ordered_json::array_tie;

use warnings;

BEGIN
{
    use Exporter ();
    our ($version, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
    
    $version = "0.01_01e";
    @ISA = qw(Exporter);
    
    @EXPORT = qw($version);
#    @EXPORT_OK = qw(&array_json_decode &new_tied);
#    %EXPORT_TAGS = ( );
}

sub TIEARRAY
{
}

return 1;
