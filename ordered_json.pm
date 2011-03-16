package ordered_json;

use warnings;
use JSON::Streaming::Reader;
use Carp;

BEGIN
{
    use Exporter ();
    our ($version, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
    
    $version = "0.01_01e";
    @ISA = qw(Exporter);
    
    @EXPORT = qw($version);
    @EXPORT_OK = qw(&array_json_decode &new_tied);
    %EXPORT_TAGS = ( );
}

sub TIEHASH
{
    my $class = shift;
    my $json_string = shift;
    my %hash;

    if(ref($json_string ) eq 'ARRAY') { $hash{array} = $json_string; }
    else { $hash{array} = array_json_decode($json_string); }

    return bless \%hash, $class;
}

sub do_something_by_key
{
    my ($this, $key, $action) = @_;
    my $value;
    my $do_search = 0;

    if(tied(%{$this->{$key}}))
    {
#	print "tied\n";
	if($action eq 'exists'){
	    $value = 1;
	} elsif( $action eq 'value'){
	    $value = $this->{$key};
	} elsif( $action eq 'value_with_offset'){
	} elsif( $action eq 'delete'){
	    $value = $this->{$key};
	    delete $this->{$key};
#	    print "deleting key \"$key\" from cache\n";
#	    print "deleted key - $this->{$key}\n";
	    $do_search = 1;
	}
#	print "dfdfd\n";
    } else { 
	$do_search = 1;
    }
    if($do_search) {
#	print "key - $key, action - $action"."\n";
#	print $this->{array}->[2]->[0]->[3]."\n";
#	print $this->{array}->[1]."\n";
#	print "ttt\n";
	while(($w_ind,$wvalue) = each(@{$this->{array}->[2]})){
#	    if ($key eq 'her' && $action eq 'value') { print "захвачен\n";}
#	    print $_->[3]."\n";
#		print $_->[4]."\n";
	    if ($wvalue->[0] eq 'object' && !defined($wvalue->[3])){ 
		while(($ww_ind, $wwvalue) = each(@{ $wvalue->[2] })){
		    if ($wwvalue->[3] eq $key){
			if(!$wwvalue->[2]){ 
			    if($action eq 'exists'){
				$value = 1;
			    } elsif( $action eq 'value'){
				$value = $wwvalue->[4];
			    } elsif($action eq 'delete'){
				$value = $wwvalue->[4];
				delete $wvalue->[2]->[$ww_ind];
#				print "привет?\n";
			    }
			} else { 
			    if($action eq 'exists'){
				$value = 1;
			    } elsif( $action eq 'value'){
				my %hash;
				tie %hash, 'ordered_json', $wvalue;
				$value = \%hash;
			    } elsif($action eq 'delete'){
				my %hash;
				tie %hash, 'ordered_json', $wvalue;
				$value = \%hash;
			    	delete $wvalue->[2]->[$ww_ind];
#				print "приветег первый раз\n";
			    }
			} 
		    }
		}
	    } elsif ($wvalue->[3] eq $key) { 
#		print $key."\n";
		if(!($wvalue->[2])){ 
		    if($action eq 'exists'){
			$value = 1;
		    } elsif( $action eq 'value'){
			$value = $wvalue->[4];
		    } elsif($action eq 'delete'){
			$value = $wwvalue->[4];
			delete $this->{array}->[2]->[$w_ind];
#			print "ПРЕВЕД!\n";
		    }
#		    print $_->[2]."\n";
		} else { 
		    if($action eq 'exists'){
			$value = 1;
		    } elsif( $action eq 'value'){
			my %hash;
			tie %hash, 'ordered_json', $wvalue;
			$value = \%hash;
		    } elsif($action eq 'delete'){
			my %hash;
			tie %hash, 'ordered_json', $wvalue;
			$value = \%hash;
			delete $this->{array}->[2]->[$w_ind];
#			print "priveteg\n";
		    }
		} 
	    }
	}
    }

    
    if(!defined($value)){
	if($action eq 'exists' | $action eq 'delete'){
	    $value = 0;
#	    print "dfdf\n";
	} elsif( $action eq 'value'){
#	    print "creating hash with key: $key\n";
	    #небольшой хак, tied hash, даже обычные хеши так себя не ведут, но удобно:D
	    my $ref = ['property', $this->{array}, 0, $key];
	    push @{$this->{array}}, $ref;
	    my %hash;
	    tie %hash, 'ordered_json', $ref;
	    $value = \%hash;
	}
#	print "value undefined\n";
    }

    if($action ne 'delete'){
#	print "end_ac: $action, end_key: $key"."\n";
	$this->{$key} = $value;
    }
#    print $this->{array}->[2]->[5]->[3]."\n";
#    print $value."\n";
    return $value;
}


sub FETCH
{
    my ($this, $key) = @_;

    return do_something_by_key($this, $key, 'value');
}



sub STORE
{
    my ($this, $key, $value) = @_;
#    print "store $key\n";

    my $key_founded = 0;
    my $tie_obj;
    
    my $field_list = $this->{array}->[2];

    foreach(@{$field_list})
    {
#	print $_->[4]."\n";
	if ($_->[0] eq 'object' && !defined($_->[3]))
	{ 
	    foreach (@{ $_->[2] })
	    {
		if ($_->[3] eq $key) 
		{ 
		    $key_founded = 1;

		    if($tie_obj = tied(%{$value})) { $_->[2] = $tie_obj->{array}; }
		    else { $_->[4] = $value; }
		}
	    }
	}
	elsif ($_->[3] eq $key) 
	{
	    $key_founded = 1;

#	    if( $tie_obj = tied(%{$value})){
#		$_->[2] =  $tie_obj{array};
#	    }else {
#		$_->[4] = $value; 
#	    }
	}
    }
    if(!$key_founded)
    {
	if( $tie_obj = tied(%{$value})){
	    push @{$field_list}, ['property', $field_list, $tie_obj->{array}, $key];
	} else {
#	    print $field_list->[0]->[0]."\n";
#	    print $key."\n";
#	    print $value."\n";
	    push @{$field_list}, ['property', $field_list, 0, $key, $value];
#	    print $field_list[5]->[4]."\n";
	}	    
    }
}

sub DELETE
{
    my ($this, $key) = @_;
#    print "delete key is: $key\n";
    return do_something_by_key($this, $key, 'delete');

}

sub EXISTS
{
    my ($this, $key) = @_;
    return do_something_by_key($this, $key, 'exists');
}

sub FIRSTKEY
{
    my $this = shift;
    $array = $this->{array}->[2];
    #print $array->[0]->[3]."\n";
    if($array){
	my $key = $array->[0]->[3];
	my $value;
	if(exists($this->{$key})){
	    $value = $this->{$key};
	} else {
	    if(!$array->[0]->[2])
	    {
		$value = $array->[0]->[4];	
		#print $value."\n";
	    } else {
		my %hash;
		tie %hash, 'ordered_json', $array->[0];
		$value = \%hash;
		$this->{$key} = $value;
	    }
	}
	return ($value, $key);
    } else {
	return undef;
    }

}

sub NEXTKEY
{
    my ($this, $key) = @_;
#    print "$key\n";
    if($key == 2){
	return undef;
    } else {
	return 2;
    }
}

sub UNTIE
{
#   print "untied\n";
}

sub DESTROY
{
#    print "destroyed\n";
}

sub json_decode { }

sub array_json_decode
{
    my $js_reader = JSON::Streaming::Reader->for_string(shift);
    # [0] - type of object - object, property
    # [1] - link to parent
    # [2] - link to array of children
    # if type is property then array consist also
    # [3] - name of property
    # [4] - value of property
    my $object = 0;
    my $cur_object = 0;

    $js_reader->process_tokens( 
	start_object => sub
	{
#	    print "start object\n";
	    if(!$object)
	    {
		$object = $cur_object = ['object', 0, 0];
	    }
	    else 
	    { 
		if(!$cur_object->[2]){
		    my $ref = ['object', $cur_object, 0];
		    $cur_object->[2] = [$ref];
		    $cur_object = $ref ;
		} else { 
		    my $ref = ['object', $cur_object, 0];
		    push @{$cur_object->[2]}, $ref;
		    $cur_object = $ref; 
		} 
	    }
	},
	
	end_object => sub {
#	    print "end object\n";
	    $cur_object = $cur_object->[1]; 
	},
	
	start_property => sub
	{
	    my $prop = shift;
#	    print "$prop\n";
	    if(!$cur_object->[2]){
#		print "$cur_object->[2]\n";
		my $ref = ['property', $cur_object, 0];
		$cur_object->[2] = [$ref];
		$cur_object = $ref;
#		print "cur_object 2 is $cur_object->[1]->[2] \n"
	    }
	    else 
	    {
#		print $cur_object->[0]."\n";
		my $ref = ['property', $cur_object, 0];
		push @{$cur_object->[2]}, $ref;
		$cur_object = $ref; 
	    } 
	    $cur_object->[3] = $prop;
	},

	end_property => sub { 
#	    print "end prop\n";
	    $cur_object = $cur_object->[1]; 
	},
	
	add_string => sub { 
#	    print "add string\n";
	    $cur_object->[4] = shift; 
	},
	#add_number => sub { $cur_object->[4] = shift; },
	#add_boolean => sub { $cur_object->[4] = shift; },
	#add_null => sub { $cur_object->[4] = 0; }
    );

    return $object;
}


return 1;
