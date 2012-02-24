use strict;
use warnings;
use File::Spec;
use Module::Build;
use vars qw/ %StarConfig /;

# Try looking up the config system
eval "use Starlink::Config qw/ :override :verbose/;";
if ($@) {
  print "Could not find Starlink::Config - using /star\n";
  %StarConfig = (
                 Star_Inc => '/star/include',
                 Star_Lib => '/star/lib',
                );
}

# This is the list of libraries required to use ems
my $gsdlibs = qx/gsd_link /;

die "No GSD libraries were found.\n This may imply that the gsd_link command is not in your path."
  if $gsdlibs !~ /./;

my $file = File::Spec->catfile( "lib", "GSD.pm" );

my $build = Module::Build->new
  (
   module_name => "GSD",
   abstract_from => $file,
   license => "gpl",
   author => [
              'Tim Jenness <tjenness@cpan.org>',
             ],
   version_from => $file,
   meta_merge => {
               resources =>  {
                              repository => "git://starlink.jach.hawaii.edu/perl-GSD.git",
                             },
                },
   script_files => [ qw/
                         gsdprint
                       /],

   build_requires => {
                      "Test::More" => 0,
                     },
   c_source => [ "arrays" ],
   extra_compiler_flags => [ "-I$StarConfig{Star_Inc}" ],
   extra_linker_flags =>  "-L$StarConfig{Star_Lib} $gsdlibs",
  );

$build->create_build_script;

