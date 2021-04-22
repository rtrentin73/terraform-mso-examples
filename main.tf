#
#  stores state @ terraform cloud
#
terraform {
  backend "remote" {
    organization = "CX-TTG"
    workspaces {
      name = "terraform-mso-examples"
    }
  }

  required_providers {
    mso = {
      source  = "CiscoDevNet/mso"
      version = "0.1.5"
    }
  }
}
#
# mso authentication
#
provider "mso" {
  username = var.mso_user
  password = var.mso_password
  url      = var.mso_url
  insecure = true
}
#
# read site info
#
data "mso_site" "site1" {
  name = "site1"
}

data "mso_site" "site2" {
  name = "site2"
}
#
# create tenant
#
resource "mso_tenant" "tenant" {
  name         = "${var.student}-lab3"
  display_name = "${var.student}-lab3"
  user_associations {
    user_id = "0000ffff0000000000000020"
  }
  user_associations {
    user_id = "60691673370000fd4a4cb4a5"
  }
  site_associations {
    site_id = data.mso_site.site1.id
  }
  site_associations {
    site_id = data.mso_site.site2.id
  }
}
#
# create schema
#
resource "mso_schema" "student-lab3-schema" {
  name          = "${var.student}-lab3-schema"
  template_name = "${var.student}-template"
  tenant_id     = mso_tenant.tenant.id
}
#
# create template
#
resource "mso_schema_template" "student-schema-template" {
  schema_id    = mso_schema.student-lab3-schema.id
  name         = "${var.student}-template"
  display_name = "${var.student}-template"
  tenant_id    = mso_tenant.tenant.id
}
#
# associate sites 
#
resource "mso_schema_site" "student-schema-site1" {
  schema_id     = mso_schema.student-lab3-schema.id
  site_id       = data.mso_site.site1.id
  template_name = "${var.student}-template"
}

resource "mso_schema_site" "student-schema-site2" {
  schema_id     = mso_schema.student-lab3-schema.id
  site_id       = data.mso_site.site2.id
  template_name = "${var.student}-template"
}
#
# create vrf 
#
resource "mso_schema_template_vrf" "student-vrf" {
  schema_id        = mso_schema.student-lab3-schema.id
  template         = "${var.student}-template"
  name             = "msm-vrf"
  display_name     = "msm-vrf"
  layer3_multicast = false
  vzany            = false
}
#
# deploy schema 
#
resource "mso_schema_template_deploy" "student-schema-deploy-site1" {
  schema_id     = mso_schema.student-lab3-schema.id
  template_name = "${var.student}-template"
  site_id       = data.mso_site.site1.id
  undeploy      = false
}

resource "mso_schema_template_deploy" "student-schema-deploy-site2" {
  schema_id     = mso_schema.student-lab3-schema.id
  template_name = "${var.student}-template"
  site_id       = data.mso_site.site2.id
  undeploy      = false
}
#
# create schema 2
#
resource "mso_schema" "student-lab3-schema-2" {
  name          = "${var.student}-lab3-schema-2"
  template_name = "${var.student}-template"
  tenant_id     = mso_tenant.tenant.id
}
#
# create template 
#
resource "mso_schema_template" "student-schema-2-template" {
  schema_id    = mso_schema.student-lab3-schema-2.id
  name         = "${var.student}-template"
  display_name = "${var.student}-template"
  tenant_id    = mso_tenant.tenant.id
}
#
# associate sites
#
resource "mso_schema_site" "student-schema-2-site1" {
  schema_id     = mso_schema.student-lab3-schema-2.id
  site_id       = data.mso_site.site1.id
  template_name = "${var.student}-template"
}

resource "mso_schema_site" "student-schema-2-site2" {
  schema_id     = mso_schema.student-lab3-schema-2.id
  site_id       = data.mso_site.site2.id
  template_name = "${var.student}-template"
}
#
# create anp
#
resource "mso_schema_template_anp" "schema-2-anp" {
  schema_id    = mso_schema.student-lab3-schema-2.id
  name         = "anp"
  display_name = "anp"
  template     = "${var.student}-template"
}
#
# create bd 
#
resource "mso_schema_template_bd" "bridge_domain-web" {
  schema_id              = mso_schema.student-lab3-schema-2.id
  template_name          = "${var.student}-template"
  name                   = "web-bd"
  display_name           = "web-bd"
  vrf_name               = mso_schema_template_vrf.student-vrf.id
  vrf_schema_id          = mso_schema.student-lab3-schema.id
  layer2_unknown_unicast = "proxy"
  intersite_bum_traffic  = "false"
}
#
# create subnet
#
resource "mso_schema_template_bd_subnet" "bdsub-web" {
  schema_id          = mso_schema.student-lab3-schema-2.id
  template_name      = "${var.student}-template"
  bd_name            = "web-bd"
  ip                 = "69.3.1.1/24"
  scope              = "public"
  description        = "Description for the subnet"
  shared             = true
  no_default_gateway = false
  querier            = true
}
#
# create bd
#
resource "mso_schema_template_bd" "bridge_domain-app" {
  schema_id              = mso_schema.student-lab3-schema-2.id
  template_name          = "${var.student}-template"
  name                   = "app-bd"
  display_name           = "app-bd"
  vrf_name               = mso_schema_template_vrf.student-vrf.id
  vrf_schema_id          = mso_schema.student-lab3-schema.id
  layer2_unknown_unicast = "proxy"
  intersite_bum_traffic  = "false"
}
#
# create subnet
#
resource "mso_schema_template_bd_subnet" "bdsub-app" {
  schema_id          = mso_schema.student-lab3-schema-2.id
  template_name      = "${var.student}-template"
  bd_name            = "app-bd"
  ip                 = "69.3.2.1/24"
  scope              = "public"
  description        = "Description for the subnet"
  shared             = true
  no_default_gateway = false
  querier            = true
}
#
# create bd
#
resource "mso_schema_template_bd" "bridge_domain-service" {
  schema_id              = mso_schema.student-lab3-schema-2.id
  template_name          = "${var.student}-template"
  name                   = "service-bd"
  display_name           = "service-bd"
  vrf_name               = mso_schema_template_vrf.student-vrf.id
  vrf_schema_id          = mso_schema.student-lab3-schema.id
  layer2_unknown_unicast = "proxy"
  intersite_bum_traffic  = "false"
}
#
# create subnet
#
resource "mso_schema_template_bd_subnet" "bdsub-service" {
  schema_id          = mso_schema.student-lab3-schema-2.id
  template_name      = "${var.student}-template"
  bd_name            = "service-bd"
  ip                 = "69.3.3.1/24"
  scope              = "public"
  description        = "Description for the subnet"
  shared             = true
  no_default_gateway = false
  querier            = true
}
#
# create epg
#
resource "mso_schema_template_anp_epg" "anp_epg-web" {
  schema_id     = mso_schema.student-lab3-schema-2.id
  template_name = "${var.student}-template"
  anp_name      = "anp"
  name          = "web"
  display_name  = "web"
  bd_name       = mso_schema_template_bd.bridge_domain-web.id
  vrf_name      = mso_schema_template_vrf.student-vrf.id
  vrf_schema_id = mso_schema.student-lab3-schema.id
}

resource "mso_schema_template_anp_epg" "anp_epg-app" {
  schema_id     = mso_schema.student-lab3-schema-2.id
  template_name = "${var.student}-template"
  anp_name      = "anp"
  name          = "app"
  display_name  = "app"
  bd_name       = mso_schema_template_bd.bridge_domain-web.id
  vrf_name      = mso_schema_template_vrf.student-vrf.id
  vrf_schema_id = mso_schema.student-lab3-schema.id
}
#
# associate vmm domain
#
resource "mso_schema_site_anp_epg_domain" "epg_web-domain" {
  schema_id            = mso_schema.student-lab3-schema-2.id
  template_name        = "${var.student}-template"
  site_id              = data.mso_site.site1.id
  anp_name             = "anp"
  epg_name             = "web"
  domain_type          = "vmmDomain"
  dn                   = "dmz-vs-site1"
  deploy_immediacy     = "lazy"
  resolution_immediacy = "lazy"
}

resource "mso_schema_site_anp_epg_domain" "epg_app-domain" {
  schema_id            = mso_schema.student-lab3-schema-2.id
  template_name        = "${var.student}-template"
  site_id              = data.mso_site.site2.id
  anp_name             = "anp"
  epg_name             = "app"
  domain_type          = "vmmDomain"
  dn                   = "dmz-vs-site2"
  deploy_immediacy     = "lazy"
  resolution_immediacy = "lazy"
}
#
# Deploy Schema 2
#
resource "mso_schema_template_deploy" "student-schema-2-deploy-site1" {
  schema_id     = mso_schema.student-lab3-schema-2.id
  template_name = "${var.student}-template"
  site_id       = data.mso_site.site1.id
  undeploy      = false
}

resource "mso_schema_template_deploy" "student-schema-2-deploy-site2" {
  schema_id     = mso_schema.student-lab3-schema-2.id
  template_name = "${var.student}-template"
  site_id       = data.mso_site.site2.id
  undeploy      = false
}
#