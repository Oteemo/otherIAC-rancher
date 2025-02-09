terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.80.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_lb" "istio_apiprivate" {
  name = var.istio_server_lb_name
}

data "aws_lb" "istio_private" {
  name = var.istio_private_lb_name
}

data "aws_lb" "istio_public" {
  name = var.istio_public_lb_name
}

data "aws_lb" "istio_server" {
  name = var.istio_server_lb_name
}

output "istio_public_name" {
  description = "AWS ALB name "
  value       = data.aws_lb.istio_public.name
}

output "istio_server_name" {
  description = "AWS ALB name "
  value       = data.aws_lb.istio_server.name
}

# These are the APP DNSes in Route 53
module "route53_app_dns_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "appdns-test"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  # TODO : Work out zone id dynamically
  zone_id               = "Z27JT8I4U0ENK1"
}

# ACORN DNS
module "acorn_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "acorn-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# ACCESS PUBLIC USER INTERFACE ( Part of MPS)
module "access_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "access-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# ARCLIGHT PUBLIC USER INTERFACE
# module "arclight_istio_alias" {
#   source                = "../../../terraform-modules/route53"
#   aws_route53_zone_name = "hz-dev.lib.harvard.edu"
#   use_cname             = false
#   alias_name            = "arclight-dev"
#   aws_route53_record    = data.aws_lb.istio_public.dns_name
#   zone_id               = "Z27JT8I4U0ENK1"
# }

# API-DEV (Part of LibraryCloud)
module "api_k8_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "api-k8s-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# ASPACE PUBLIC USER INTERFACE
module "aspacepui_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "aspacepui-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# ASPACE API
module "aspaceapi_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "aspaceapi-dev"
  aws_route53_record    = data.aws_lb.istio_apiprivate.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# ASPACE STAFF
module "aspace_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "aspace-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# BIBDATA DNS
module "bibdata_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "bibdata-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# BOOKLABELER DNS
module "booklabeler_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "booklabeler-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# CURIOSITY
module "curiosity_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "curiosity-dev"
  # TODO : Work out dynamically
  aws_route53_record    = "internal-curiosity-1890483604.us-east-1.elb.amazonaws.com"
  zone_id               = "Z27JT8I4U0ENK1"
}

# COLLEX
module "collex_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "collex-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# DAIS
module "dims_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "dims-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# DRS MDS SRV  - Part of MDS
module "drsmdsrv_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "drsmdsrv-dev"
  aws_route53_record    = data.aws_lb.istio_server.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# DRS MQ SRV  - Part of MDS
module "drsmqsrv_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "drsmqsrv-dev"
  aws_route53_record    = data.aws_lb.istio_server.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# DRS SRV
module "drssrv_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "drs2"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# DRS SERVICE
module "drs2service_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "drs2-services"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# EADCHECKER
module "eadchecker_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "eadchecker-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# EDA
module "eda_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "eda-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# ETD
module "etd_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "etd-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# FEEDBACK
module "feedback_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "feedback-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# FTS
module "fts_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "fts-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# HD FORMS
module "hdforms_tools_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "tools-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# HGL
module "hgl_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "hgl-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# ID
module "id-dev_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "id-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# IDS
module "ids_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "ids-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# INLIB ADM (part of MPS)
module "inlib_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "inlib-adm-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# OLIVIA
module "olivia_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "olivia-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# IIF
module "iif_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "iif-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# IMGCONV
module "imgconv_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "imgconv-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# JOB MONITOR
module "jobmon_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "jobmon-dev"
  aws_route53_record    = data.aws_lb.istio_server.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# JSTOR
module "jstor_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "jstor-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# LC-Tools
module "lctools_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "lc-tools-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# LTS-Pipeline
module "ltspipelines_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "lts-pipelines-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# LISTVIEW
module "listview_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "listview-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# MPS
module "mps_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "mps-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# MPSADMIN
module "mpsadmin_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "mps-admin-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# FDS - part of MPS
module "fds_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "fds-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# NRS
module "nrs_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "nrs-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# NRSADM
module "nrsadm_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "nrsadm-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# NRSADM API
module "nrsadm_api_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "nrsadmin-api-dev"
  aws_route53_record    = data.aws_lb.istio_server.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# PDS
module "pds_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "pds-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# POLICY
module "policy_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "policyadmin-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# SECUREEXIT
module "secureexit_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "secureexit-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# TALKWITHHOLLIS
module "talkwithhollis_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "talkwithhollis-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# VIEWER
module "viewer_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "viewer-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# WEBSERVICES (Presto)
module "webservices_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "webservices-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# WHISTLE (Starfish)
module "whistle_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "whistle-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

# WORDSHACK
module "wordshack_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "wordshack-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

module "embed_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "embed-dev"
  aws_route53_record    = data.aws_lb.istio_public.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

module "iiif-update_istio_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "iiif-update-dev"
  aws_route53_record    = data.aws_lb.istio_server.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

module "drs-file-api-dev" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "drs-file-api"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}

#AQUEDUCT
module "aqueduct_dev_alias" {
  source                = "../../../terraform-modules/route53"
  aws_route53_zone_name = "hz-dev.lib.harvard.edu"
  use_cname             = false
  alias_name            = "aqueduct-dev"
  aws_route53_record    = data.aws_lb.istio_private.dns_name
  zone_id               = "Z27JT8I4U0ENK1"
}