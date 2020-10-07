#include <stdio.h>
#include <stdlib.h>
#include <gsl/gsl_histogram.h>
#include <gsl/gsl_histogram2d.h>
#include <gsl/gsl_errno.h>

int mgsl_histogram_fwrite(const char *filename, const gsl_histogram *h)
{
  FILE *fp;
  if((fp = fopen(filename, "w")) == NULL) return GSL_EFAILED;
  if(gsl_histogram_fwrite(fp, h) != GSL_SUCCESS) return GSL_EFAILED;
  fclose(fp);
  return GSL_SUCCESS;
}

int mgsl_histogram_fread(const char *filename, gsl_histogram *h)
{
  FILE *fp;
  if((fp = fopen(filename, "r")) == NULL) return GSL_EFAILED;
  if(gsl_histogram_fread(fp, h) != GSL_SUCCESS) return GSL_EFAILED;
  fclose(fp);
  return GSL_SUCCESS;
}

int mgsl_histogram_fprintf(const char *filename, const gsl_histogram *h, const char *range_format, const char *bin_format)
{
  FILE *fp;
  if((fp = fopen(filename, "w")) == NULL) return GSL_EFAILED;
  if(gsl_histogram_fprintf(fp, h, range_format, bin_format) != GSL_SUCCESS) return GSL_EFAILED;
  fclose(fp);
  return GSL_SUCCESS;
}

int mgsl_histogram_fscanf(const char *filename, gsl_histogram *h)
{
  FILE *fp;
  if((fp = fopen(filename, "r")) == NULL) return GSL_EFAILED;
  if(gsl_histogram_fscanf(fp, h) != GSL_SUCCESS) return GSL_EFAILED;
  fclose(fp);
  return GSL_SUCCESS;
}

int mgsl_histogram2d_fwrite(const char *filename, const gsl_histogram2d *h)
{
  FILE *fp;
  if((fp = fopen(filename, "w")) == NULL) return GSL_EFAILED;
  if(gsl_histogram2d_fwrite(fp, h) != GSL_SUCCESS) return GSL_EFAILED;
  fclose(fp);
  return GSL_SUCCESS;
}

int mgsl_histogram2d_fread(const char *filename, gsl_histogram2d *h)
{
  FILE *fp;
  if((fp = fopen(filename, "r")) == NULL) return GSL_EFAILED;
  if(gsl_histogram2d_fread(fp, h) != GSL_SUCCESS) return GSL_EFAILED;
  fclose(fp);
  return GSL_SUCCESS;
}

int mgsl_histogram2d_fprintf(const char *filename, const gsl_histogram2d *h, const char *range_format, const char *bin_format)
{
  FILE *fp;
  if((fp = fopen(filename, "w")) == NULL) return GSL_EFAILED;
  if(gsl_histogram2d_fprintf(fp, h, range_format, bin_format) != GSL_SUCCESS) return GSL_EFAILED;
  fclose(fp);
  return GSL_SUCCESS;
}

int mgsl_histogram2d_fscanf(const char *filename, gsl_histogram2d *h)
{
  FILE *fp;
  if((fp = fopen(filename, "r")) == NULL) return GSL_EFAILED;
  if(gsl_histogram2d_fscanf(fp, h) != GSL_SUCCESS) return GSL_EFAILED;
  fclose(fp);
  return GSL_SUCCESS;
}
