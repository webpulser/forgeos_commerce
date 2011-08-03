########################################################################################
# Warning !! CMCIC_Config contains the key, you have to protect this file with all     #
# the mechanism available in your development environment.                             #
# You may for instance put this file in another directory and/or change its name       #
########################################################################################
setting = Setting.current
if setting and cmc_cic_tmp = setting.payment_method_settings(:cmc_cic)
  CMCIC_CLE = cmc_cic[:cle]
  CMCIC_TPE = cmc_cic[:tpe]
  CMCIC_VERSION = cmc_cic[:version]
  CMCIC_SERVEUR = cmc_cic[:serveur]
  CMCIC_CODESOCIETE = cmc_cic[:code_societe]
  CMCIC_URLOK = cmc_cic[:url_ok]
  CMCIC_URLKO = cmc_cic[:url_ko]
  CMCIC_URL_RETURN = cmc_cic[:url_return]
end
