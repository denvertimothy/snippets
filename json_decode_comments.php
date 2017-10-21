<?
	public function json_decode_comments($json, $assoc=false, $depth=512, $options=0) {
		$json = preg_replace("#(/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/)|([\s\t]//.*)|(^//.*)#", '', $json);
		if(version_compare(phpversion(), '5.4.0', '>=')):
			return json_decode($json, $assoc, $depth, $options);
		elseif(version_compare(phpversion(), '5.3.0', '>=')):
			return json_decode($json, $assoc, $depth);
		else:
			return json_decode($json, $assoc);
		endif;
	}
?>
