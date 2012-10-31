# This subclass only exists so we can have SimpleForm assign the css class of
# 'destroy' rather than 'boolean' to an input.
class DestroyInput < SimpleForm::Inputs::BooleanInput
end
