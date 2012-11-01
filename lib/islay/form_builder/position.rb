# This subclass only exists so we can have SimpleForm assign the css class of
# 'position' rather than 'integer' to an input.
class PositionInput < SimpleForm::Inputs::NumericInput
end
