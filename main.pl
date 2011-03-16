#!/usr/bin/perl

use Gtk2 -init;
use Glib;

sub main_handler
{
    my $window = shift;
    Gtk2::main_quit;
}

sub update_main_area
{
    my $area_widget;
    sub create_and_fill_model
    {
	my $folder_icon;
	eval
	{
	    $folder_icon = Gtk2::Gdk::Pixbuf->new_from_file('/usr/share/icons/gnome/48x48/places/folder.png');
	};
#	print "$@\n";
	my $list_store = Gtk2::ListStore::new(20,Glib::String,Gtk2::Gdk::Pixbuf);
#	my $iter = Gtk2::TreeIter::new;
	$iter = $list_store->append;
	$list_store->set($iter,0,'Folder',1,$folder_icon);
	$iter = $list_store->append;
	$list_store->set($iter,0,'Folder',1,$folder_icon);
	$iter = $list_store->append;
	$list_store->set($iter,0,'Folder',1,$folder_icon);
	$iter = $list_store->append;
	$list_store->set($iter,0,'Folder',1,$folder_icon);
	$iter = $list_store->append;
	$list_store->set($iter,0,'Folder',1,$folder_icon);
	$iter = $list_store->append;
	$list_store->set($iter,0,'Folder',1,$folder_icon);
	$iter = $list_store->append;
	$list_store->set($iter,0,'Folder',1,$folder_icon);
	$iter = $list_store->append;
	$list_store->set($iter,0,'Folder',1,$folder_icon);
	$iter = $list_store->append;
	$list_store->set($iter,0,'Folder',1,$folder_icon);
	#print $folder_icon-> 
	return $list_store;
    }
$area_widget = Gtk2::IconView->new_with_model(create_and_fill_model);
$area_widget->set_text_column(0);
$area_widget->set_pixbuf_column(1);
$area_widget->set_selection_mode(GTK_SELECTION_SINGLE);
    return $area_widget;
}

my $builder = Gtk2::Builder->new;
$builder->add_from_file('main.ui');
$builder->connect_signals;

my $window = $builder->get_object('window_main');
my $icons_sw = $builder->get_object('icons_sw');
$window->set_title('dubase_proto');
$window->set_default_size(600,100);
$window->set_resizable(true);
#$window->show_all;
my $area_widget = update_main_area;
$area_widget->show;
$icons_sw->add($area_widget);
#$work_area_vbox->add($area_widget);

#Gtk2->main;


sub make_shema_array
{
    open shema_handle,"<entities/shemas/state.json";
    @state = <shema_handle>;
    #$json_array = array_json_decode("@state");
#    print "@state\n";
    my $oj;
    {
	tie %oj, 'ordered_json', "@state";
	
	$oj{pi} = "dfdf";
#     $p = $oj{name}->{prop};
#	print "$oj{name}->{prop}->{type}"."\n";
	$oj{name}->{prop}->{types}->{top} = 'grand';
	$oj{name}->{prop}->{types}->{tope} = 'grande';
	$oj{name}->{prop}->{types}->{topi}->{her} = 'grander';
	
#	print "$oj{name}->{prop}->{types}->{top}\n";#
#	print "$oj{name}->{prop}->{types}->{tope}\n";
#	print (delete $oj{name}->{prop}->{types}->{topi})."\n";
#	print "$oj{name}->{prop}->{types}->{topi}->{her}\n";
#	print exists($oj{name}->{prop})."\n";
#	$oj = \%oj;
	while (($key,$value) = each %oj)
	{
	    print $key."\n";
	}
    }
#    print "tiger\n";
    $oj = 0;
}

use ordered_json;

$object = make_shema_array;
#print "dfdf\n";
#print $object->[0]."\n";
#print $object->[2]->[0]->[0]."\n";
#print $object->[2]->[0]->[3]."\n";
#print $object->[2]->[1]->[0]."\n";
#print $object->[2]->[1]->[3]."\n";
#print $object->[2]->[2]->[0]."\n";
#print $object->[2]->[2]->[3]."\n";
#print $object->[2]->[3]->[0]."\n";
#print $object->[2]->[3]->[3]."\n";
#print $object->[2]->[4]->[0]."\n";
#print $object->[2]->[4]->[3]."\n";
#print $object->[2]->[5]->[0]."\n";
#print $object->[2]->[5]->[3]."\n";
#print $object->[2]->[6]->[0]."\n";
#print $object->[2]->[6]->[3]."\n";
#print $object->[2]->[5]->[2]->[0]->[2]->[0]->[4]."\n";
#foreach (@{$object->[2]})
#{
#    print $_."_\n"; 
#}
#print "_|".$object->[2]->[0]."|_\n";
#print "_|".$object->[2]->[0]->[4]."|_\n";
#foreach (make_shema_array)
#{
#    if (ref($_) eq '') { print "Object is : $_->[0] \n"; }
#    else { print "$_->[0] $_->[1] \n"; }
#}
#$state = decode_json(\"@state");

#foreach (%{$state})
#{
#    print $_."\n";
#}

#print "hoi\n";
