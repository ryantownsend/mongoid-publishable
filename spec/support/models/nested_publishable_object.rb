require_relative "publishable_object"

class ParentPublishableObject < PublishableObject
  embeds_many :nested_objects, class_name: "NestedPublishableObject"
end

class NestedPublishableObject < PublishableObject
  embedded_in :parent_publishable, class_name: "ParentPublishableObject", inverse_of: :nested_objects
end