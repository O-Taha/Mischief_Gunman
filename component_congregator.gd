@tool #ATTENTION DOESN'T WORK...
extends Node

@export_category("Components & Attributes")
# Credits to dbat & damvcoool (https://forum.godotengine.org/t/conditionally-show-exported-variables/43678/2)
const HEALTH_COMPONENT: int = 1
const RICOCHET_COMPONENT: int = 2
const COVER_COMPONENT: int = 4

@export_flags("Health", "Ricochet", "Cover") var components = 0:
	set(value):
		if value == components: return
		components = value
		_update_components()
		notify_property_list_changed()
		
var health: float:
	set(value):
		health = value
		#if component_congregator:
			#print(component_congregator.get_children())

var possible_components: Dictionary[int, PackedScene] = {
	HEALTH_COMPONENT: ResourceLoader.load("res://Scenes/Components/health_component.tscn")
	}

var added_components: Dictionary[int, Node]
var component_properties := {}

func _get_property_list():
	if not Engine.is_editor_hint():
		return []
	var props := []
	for mask in component_properties.keys():
		props.append_array(component_properties[mask])
	return props


func _update_components():
	# --- SAFETY : required for @tool scripts in editor ---
	if Engine.is_editor_hint():
		await get_tree().process_frame
	if not is_inside_tree():
		return

	# --- Remove ---
	for mask in added_components.keys():
		if not (components & mask):
			if added_components[mask].is_inside_tree():
				added_components[mask].queue_free()
			added_components.erase(mask)
			component_properties.erase(mask)

	# --- Add ---
	for mask in possible_components.keys():
		if (components & mask) and not added_components.has(mask):

			var inst = possible_components[mask].instantiate()
			add_child(inst)
			inst.owner = self.owner  # OK only now

			added_components[mask] = inst
			component_properties[mask] = add_component_properties_to_inspector_for(mask)


func add_component_properties_to_inspector_for(component_mask: int) -> Array[Dictionary]:
	var properties: Array[Dictionary] = added_components[component_mask].get_property_list()
	return filter_component_properties_only(properties)
	
func filter_component_properties_only(properties: Array[Dictionary]) -> Array[Dictionary]:
	# Only adds user-defined properties as opposed to built-in ones (i.e. in the script) :
	var start_of_script_variables: int = properties.rfind_custom(func (property): return ".gd" in property.name) 
	properties = properties.slice(start_of_script_variables)
	properties[1].usage |= PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED
	#print(JSON.stringify(properties, "  "))
	return properties
	
func _set(property: StringName, val: Variant) -> bool: # (http://kehomsforge.com/tutorials/single/conditionally-export-properties-godot/)
	# Assume the property exists
	var retval: bool = true
	match property:
		"Health":
			health = val
			added_components[HEALTH_COMPONENT].health = val
			added_components[HEALTH_COMPONENT].notify_property_list_changed()
		_:
			# If here, trying to set a property we are not manually dealing with.
			retval = false
	return retval

func _get(prop_name: StringName):
	match prop_name:
		"health":
			return added_components[HEALTH_COMPONENT].health
	return null
