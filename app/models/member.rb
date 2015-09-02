class Member < ParseResource::Base
	fields :email, :name, :type
		
	def self.get_member_type(email)
		if email == nil
			return 'student'
		end
		members = Member.where(email:email).to_a
		if members.length == 0
			return 'student'
		end
		if members[0].type == 'instructor'
			return 'instructor'
		end
		return 'student'
	end
end