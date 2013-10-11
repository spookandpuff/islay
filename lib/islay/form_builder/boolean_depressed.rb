# This subclass only exists so we can have SimpleForm assign the css class of
# 'boolean_depressed' rather than 'boolean' to an input.
class BooleanDepressedInput < SimpleForm::Inputs::BooleanInput
end
