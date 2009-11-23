use strict;
use warnings;

use Test::More;

use lib 't/lib';

use File::Basename qw( basename );
use File::Find qw( find );
use File::Slurp qw( read_file );
use Test::Markdent;

my @files;
find(
    {
        wanted => sub {
            return unless $File::Find::name =~ /\.text$/;

            ( my $html_file = $File::Find::name ) =~ s/\.text$/.xhtml/;

            return unless -f $html_file;

            push @files, [ $File::Find::name, $html_file ];
        },
        no_chdir => 1,
    },
    't/mdtest-data'
);

plan tests => scalar @files;

for my $pair ( sort @files ) {
    my ( $md_file, $html_file ) = @{$pair};

    my $markdown    = read_file($md_file);
    my $expect_html = read_file($html_file);

    my $desc = basename($md_file);
    $desc =~ s/\.text$//;

    html_output_ok( $markdown, $expect_html, $desc );
}
