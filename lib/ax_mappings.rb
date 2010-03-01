# list from http://www.axschema.org/types/
 AX_MAPPINGS = {  
   :nickname => "http://axschema.org/namePerson/friendly",
   :email => "http://axschema.org/contact/email",
   :fullname => "http://axschema.org/namePerson",
   :dob => "http://axschema.org/birthDate",
   :gender => "http://axschema.org/person/gender",
   :language => "http://axschema.org/pref/language",
   :timezone => "http://axschema.org/pref/timezone",
   :last_name => "http://axschema.org/namePerson/last",
   :first_name => "http://axschema.org/namePerson/first",
   :prefix => "http://axschema.org/namePerson/prefix",
   :middle_name => "http://axschema.org/namePerson/middle",
   :suffix => "http://axschema.org/namePerson/suffix",
   :company_name => "http://axschema.org/company/name",
   :title => "http://axschema.org/company/title",
   :birth_year => "http://axschema.org/birthDate/birthYear",
   :birth_month => "http://axschema.org/birthDate/birthMonth",
   :birthday => "http://axschema.org/birthDate/birthday",
   :phone => "http://axschema.org/contact/phone/default",
   :phone_home => "http://axschema.org/contact/phone/home",
   :phone_work => "http://axschema.org/contact/phone/business",
   :phone_mobile => "http://axschema.org/contact/phone/cell",
   :phone_fax => "http://axschema.org/contact/phone/fax",
   
   :home_address     => "http://axschema.org/contact/postalAddress/home",
   :home_address_2   => "http://axschema.org/contact/postalAddressAdditional/home",
   :home_city        => "http://axschema.org/contact/city/home",
   :home_state       => "http://axschema.org/contact/state/home",
   :home_country     => "http://axschema.org/contact/country/home",
   :home_postal_code => "http://axschema.org/contact/postalCode/home",
   
   :work_address     => "http://axschema.org/contact/postalAddress/business",
   :work_address_2   => "http://axschema.org/contact/postalAddressAdditional/business",
   :work_city        => "http://axschema.org/contact/city/business",
   :work_state       => "http://axschema.org/contact/state/business",
   :work_country     => "http://axschema.org/contact/country/business",
   :work_postal_code => "http://axschema.org/contact/postalCode/business",

   :im_aim => "http://axschema.org/contact/IM/AIM",
   :im_icq => "http://axschema.org/contact/IM/ICQ",
   :im_msn => "http://axschema.org/contact/IM/MSN",
   :im_yahoo => "http://axschema.org/contact/IM/Yahoo",
   :im_jabber => "http://axschema.org/contact/IM/Jabber",
   :im_skype => "http://axschema.org/contact/IM/Skype",

   :web_default => "http://axschema.org/contact/web/default",
   :web_blog => "http://axschema.org/contact/web/blog",
   :web_linked_in => "http://axschema.org/contact/web/Linkedin",
   :web_amazon => "http://axschema.org/contact/web/amazon",
   :web_flickr => "http://axschema.org/contact/web/Flickr",
   :web_delicious => "http://axschema.org/contact/web/Delicious",
   
   :media_spokenname => "http://axschema.org/media/spokenname",
   :media_audio_greeting =>"http://axschema.org/media/greeting/audio",
   :media_video_greeting =>"http://axschema.org/media/greeting/video",
   
   :image => "http://axschema.org/media/image/default",
   :image_aspect11 => "http://axschema.org/media/image/aspect11",
   :image_aspect43 => "http://axschema.org/media/image/aspect43",
   :image_aspect34 => "http://axschema.org/media/image/aspect34",
   :favicon => "http://axschema.org/media/image/favicon",
   :gender =>  "http://axschema.org/person/gender",
   :biography => "http://axschema.org/media/biography"
 }
 
 
INVERTED_AX_MAPPINGS = AX_MAPPINGS.invert
