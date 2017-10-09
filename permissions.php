<?
	class Permissions {
		
		const none = 0;
		const select = 1;
		const update = 2;
		const insert = 4;
		const delete = 8;
		const manager = 16;
		const admin = 32;
		
		static function check($permissions_id, $grants, $user_id=null)
		{
			// get user ID
			$user_id = $user_id ?? $_SESSION['user']['id'] ?? null;
			if($user_id == null) throw new Exception("Could not get user ID to check permissions.");
			
			// check permissions
			$perms = (bool)DB::query("SELECT system_permissions_check($1, $2, $3::INTEGER::BIT(6))::INTEGER AS permissions",
				[$user_id, $permissions_id, $grants])->single()['permissions'];
			
			return $perms;
		}
		
	}
?>
