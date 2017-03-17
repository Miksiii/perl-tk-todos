#! C:\Strawberry\perl\bin\perl.exe

use strict;
use warnings;
use 5.010;
use Tk;
use Tk::DialogBox;
use List::MoreUtils qw(firstidx);

my $mw = new MainWindow;
$mw->title("Super Cool App");
$mw->configure(-bg => "white");
$mw->protocol('WM_DELETE_WINDOW' => \&on_exit_save_todos);

my $label_input = $mw->Label(-text => "Add new ToDo", -bg => "white", -width => 30)
                     ->grid(-column => 0, -row => 0);

my $input = $mw->Entry(-text => "", -width => 30)
               ->grid(-column => 0, -row => 1);

my $button = $mw->Button(-text => "Add", -bg => "blue", 
                         -foreground => "white", -width => 30,
                         -command => \&item_add)
                ->grid(-column => 0, -row => 2);              

my $listbox = $mw->Listbox(-width => 30)
                ->grid(-column => 0, -row => 3);  

my $label_output = $mw->Label(-text => "", -bg => "white", -width => 30)
                     ->grid(-column => 0, -row => 4);                 

my @todos = ();

if ( open(my $fh, '<', 'todos.txt') ) {
  while(<$fh>) {
    chomp $_;
    push(@todos, $_);
  }
  $label_output->configure(-text => scalar @todos . " items loaded");
  close($fh);
}

$listbox->insert('end', @todos);
$listbox->bind('<Double-1>', \&item_check);

sub item_add {
  if($input->get() eq "") { 
    $label_output->configure(-text => "Cannot add blanko");
    return;
  }

  $listbox->delete(0, 'end');
  push(@todos, $input->get());
  $listbox->insert('end', @todos);
  $input->delete(0, 'end');
  $label_output->configure(-text => "Item added");
}

sub item_check {
  my $dialog_box = $mw->DialogBox(-title => 'Wow, already done?', -buttons => ["Yes", "No"]);
  my $dialog_box_answer = $dialog_box->Show();

  if ($dialog_box_answer eq "No") { return; }
    my $todo_item = $_[0]->get($_[0]->curselection);
    my $todo_item_index = firstidx { $_ eq $todo_item } @todos;
    splice(@todos, $todo_item_index, 1);

    $listbox->delete(0, 'end');
    $listbox->insert('end', @todos);

    $label_output->configure(-text => 'One item removed.');
}

sub on_exit_save_todos {
  if ( open(my $fh, '>', 'todos.txt') ) {
    for (@todos) {
      say $fh $_;
    }
  }

  exit;
}

MainLoop;
