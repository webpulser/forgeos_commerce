# *****************************************************************************
#
# "Open source" kit for CM-CIC P@iement (TM)
# 
# File "CMCIC_Tpe.rb":
# 
# Author   : Euro-Information/e-Commerce (contact: centrecom@e-i.com)
# Version  : 1.04
# Date     : 01/01/2009
# 
# Copyright: (c) 2009 Euro-Information. All rights reserved.
# License  : see attached document "License.txt".
# 
# *****************************************************************************

CMCIC_URLPAIEMENT = "paiement.cgi"

#*****************************************************************************
#
# Classe / Class : CMCIC_Tpe
#
#*****************************************************************************

class CMCIC_Tpe

	# ----------------------------------------------------------------------------
	#
	# Constructeur / Constructor
	#
	# ----------------------------------------------------------------------------

	def initialize(sLang = "FR")

		aRequiredConstants = ['CMCIC_CLE', 'CMCIC_VERSION', 'CMCIC_TPE', 'CMCIC_CODESOCIETE'];

		_checkTpeParams(aRequiredConstants)

		@sVersion = CMCIC_VERSION
		@_sCle = CMCIC_CLE
		@sNumero = CMCIC_TPE
		@sUrlPaiement = CMCIC_SERVEUR + CMCIC_URLPAIEMENT

		@sCodeSociete = CMCIC_CODESOCIETE
		@sLangue = sLang

		@sUrlOk = CMCIC_URLOK
		@sUrlKo = CMCIC_URLKO
	end

	def sVersion
		@sVersion
	end

	def sNumero
		@sNumero
	end

	def sCodeSociete
		@sCodeSociete
	end
	
	def sLangue
		@sLangue
	end

	def sUrlPaiement
		@sUrlPaiement
	end

	def sUrlOk
		@sUrlOk
	end

	def sUrlKo
		@sUrlKo
	end

	def getCle
		@_sCle
	end

	private 

	# ----------------------------------------------------------------------------
	#
	# Fonction / Function : _checkTpeParams
	#
	# Check for the initialising constants of the TPE
	#
	# ----------------------------------------------------------------------------

	def _checkTpeParams(aParams) 

		for sParam in aParams
			if !defined?(sParam)
				puts "Erreur paramètre " + sParam + " indéfini"
				Process.exit
			end
		end
	end
end

# ----------------------------------------------------------------------------
#
# XOR implementation for strings
#
# ----------------------------------------------------------------------------

class String
	def ^(other)
		raise ArgumentError, "Can't bitwise-XOR a String with a non-String" \
			unless other.kind_of? String
		raise ArgumentError, "Can't bitwise-XOR strings of different length" \
			unless self.length == other.length

		result = (0..self.length-1).collect { |i| self[i] ^ other[i] }
		result.pack("C*")
	end
end


#*****************************************************************************
#
# Classe / Class : CMCIC_Tpe
#
#*****************************************************************************

class CMCIC_Hmac
	require 'digest/sha1'

	# ----------------------------------------------------------------------------
	#
	# Constructeur / Constructor
	#
	# ----------------------------------------------------------------------------

	def initialize(oTpe)

		@_sUsableKey = _getUsableKey(oTpe)
	end

	# ----------------------------------------------------------------------------
	#
	# Fonction / Function : computeHMACSHA1
	#
	# Return the HMAC for a data string
	#
	# ----------------------------------------------------------------------------

	def computeHMACSHA1(sData)

		hmac_sha1(@_sUsableKey, sData).downcase
	end

	# ----------------------------------------------------------------------------
	#
	# Fonction / Function : isValidHmac
	#
	# Check if the HMAC matches the HMAC of the data string
	#
	# ----------------------------------------------------------------------------

	def isValidHmac?(sChaineMac, sSentMac)

		computeHMACSHA1(sChaineMac) == sSentMac.downcase
	end

	# ----------------------------------------------------------------------------
	#
	# Fonction / Function : hmac_sha1
	#
	# RFC 2104 HMAC implementation for Ruby
	# Eliminates the need to install mhash to compute a HMAC
	# Adjusted from the md5 version by Lance Rushing
	#
	# Note :
	# It is also possible to use
	# require 'openssl'
	# OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new("sha1"), key, data)
	#
	# ----------------------------------------------------------------------------

	def hmac_sha1(sKey, sData)
		length = 64

		if (sKey.length > length) 
			sKey = [Digest::SHA1.hexdigest(sKey)].pack("H*")
		end

		sKey  = sKey.ljust(length, 0.chr)
		ipad = ''.ljust(length, 54.chr)
		opad = ''.ljust(length, 92.chr)

		k_ipad = sKey ^ ipad
		k_opad = sKey ^ opad

		Digest::SHA1.hexdigest(k_opad + [Digest::SHA1.hexdigest(k_ipad + sData)].pack("H*"))
	end

	private

	# ----------------------------------------------------------------------------
	#
	# Fonction / Function : _getUsableKey
	#
	# Return the key to be used in the hmac function
	#
	# ----------------------------------------------------------------------------

	def _getUsableKey(oTpe)

		hexStrKey  = oTpe.getCle[0..37]
		hexFinal   = oTpe.getCle[38..40] + "00";

		cca0=hexFinal[0]

		if cca0>70 and cca0<97
			hexStrKey += (cca0-23).chr + hexFinal[1..2]
		elsif hexFinal[1..2] == "M" 
			hexStrKey += hexFinal[0..1] + "0" 
		else 
			hexStrKey += hexFinal[0..2]
		end

		[hexStrKey].pack("H*")
	end 
end
