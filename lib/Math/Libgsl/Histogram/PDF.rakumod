use v6;

unit class Math::Libgsl::Histogram::PDF:ver<0.1.1>:auth<zef:FRITH>;

use NativeCall;
use Math::Libgsl::Constants;
use Math::Libgsl::Exception;
use Math::Libgsl::Raw::Histogram;
use Math::Libgsl::Histogram;

has gsl_histogram_pdf $.hpdf;

multi method new(UInt $size!, Math::Libgsl::Histogram $h!)   { self.bless(:$size, :$h) }
multi method new(UInt :$size!, Math::Libgsl::Histogram :$h!) { self.bless(:$size, :$h) }
submethod BUILD(UInt :$size, Math::Libgsl::Histogram :$h) {
  $!hpdf = gsl_histogram_pdf_alloc($size);
  gsl_histogram_pdf_init($!hpdf, $h.h);
}
submethod DESTROY { gsl_histogram_pdf_free($!hpdf) }
method sample(Num() $r --> Num) { gsl_histogram_pdf_sample($!hpdf, $r) }
