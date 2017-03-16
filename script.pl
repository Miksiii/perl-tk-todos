#! C:\Strawberry\perl\bin\perl.exe

use strict;
use warnings;
use 5.010;
use Tk;
use Tk::DialogBox;
use List::MoreUtils qw(firstidx);
use Time::HiRes;

my $mw = new MainWindow;
$mw->title("To-Do App");
$mw->configure(-bg => 'white');
$mw->protocol('WM_DELETE_WINDOW' => \&on_exit_save_todos);

my @todos = ();

my $l_input  = $mw->Label(-bg => 'white', -text => 'Add new To-Do') 
               ->pack(-ipady => 20)
               ->grid(-column => 1, -row=>0);

my $input    = $mw->Entry(-text => '') 
               ->pack(-side => 'left')
               ->grid(-column => 1, -row=>1);

my $button   = $mw->Button(-background => 'blue', -foreground => 'white', -text => 'Add', -width => 19, -command => \&item_add) 
               ->pack(-side => 'right')
               ->grid(-column => 1, -row=>2);

my $listBox  = $mw->Listbox()
               ->pack(-side => 'left')
               ->grid(-column => 1, -row=>3);

my $l_output = $mw->Label(-bg => 'white', -text => '') 
               ->pack(-ipady => 20)
               ->grid(-column => 1, -row=>4);              

$listBox -> bind('<Double-1>'=> \&item_check);

if (open(my $fh, '<', 'todos.txt')) {
  $l_output->configure(-text => 'All todos loaded.');

  while(<$fh>) {
    chomp $_;
    push(@todos, $_);
  }

  close($fh);
}

$listBox -> insert('end', @todos );

sub item_add {
  if ($input->get() eq "") {
    $l_output->configure(-text => 'Cannot add nothing..');
    return
  } ;

  $listBox->delete(0, 'end');
  push(@todos, $input->get());
  $listBox->insert('end', @todos);
  $input->delete(0, 'end');

  $l_output->configure(-text => 'New item added.');
}

sub item_check {
  my $dialog = $mw->DialogBox (-title => "Already done?", -buttons => ["Yes", "No"]);
  my $dialog_answer = $dialog->Show();

  if ($dialog_answer eq "Yes") {
    my $item_selected = $_[0]->get($_[0]->curselection);
    my $item_index = firstidx { $_ eq $item_selected } @todos;
    splice(@todos, $item_index, 1);
    $listBox->delete(0, 'end');
    $listBox->insert('end', @todos );

    $l_output->configure(-text => 'One item removed.');
  }

}

sub on_exit_save_todos {
  if (open(my $fh, '>', 'todos.txt')) {
    for (@todos) {
      say $fh $_; 
    }
  }

  exit;
}

MainLoop;