@abstract
class_name SerializedResource
extends Resource
## A type of resource that gets stored in shareable [Stage] codes.

## Take this resource's data, and serialize it into a piece of level code.
## Make sure this piece can be read by the [method deserialize] method.
@abstract func serialize() -> String


## Take a piece of level code created by the [method serialize] method and decode it,
## then plug that data into this object's properties.
@abstract func deserialize(_serialized_str: String) -> Error
