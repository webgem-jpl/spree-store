module Spree
    module Api
        module V1
            class PrototypeController < Spree::Api::BaseController

                def index
                    if params['sale_channel']
                        value = ActiveRecord::Type::Boolean.new.cast(params['sale_channel'])
                        @prototypes = Spree::Prototype.where(sale_channel:value).includes(:properties, :taxons, :option_types => :option_values).all
                    else
                        @prototypes = Spree::Prototype.includes(:properties, :taxons, :option_types => :option_values).all
                    end
                    render json: {
                    prototypes: @prototypes.as_json(:include => {
                        :option_types => {:include => :option_values}, :properties => {:include => nil}, :taxons => {:include => nil}}
                        )
                    }, status: 200
                end

            end
        end
    end
end