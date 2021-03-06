class SignaturesController < ApplicationController
  before_filter :retrieve_petition, :only => [:new, :create, :thank_you, :signed]
  ssl_required :new, :create
  ssl_allowed :thank_you, :verify
  include ActionView::Helpers::NumberHelper

  respond_to :html

  def new
    @signature = Signature.new(:petition => @petition, :country => "United Kingdom")
  end

  def create
    params[:signature][:humanity] = Captcha.verify(params[:captcha_response_field], params[:captcha_string])

    @signature = Signature.new(params[:signature])
    @signature.email.strip!
    @signature.petition = @petition
    if (@signature.save)
      send_email_to_petition_signer(@signature)
    end
    respond_with @signature, :location => thank_you_petition_signature_path(@petition)
  end

  def verify
    @signature = Signature.find(params[:id])

    if @signature.perishable_token == params[:token]
      @signature.perishable_token = nil
      @signature.state = Signature::VALIDATED_STATE
      @signature.save(:validate => false)

      # if signature is that of the petition's creator, mark the petition as validated
      if @signature.petition.creator_signature == @signature
        @signature.petition.state = Petition::VALIDATED_STATE
        @signature.petition.save!

    # else signature is from an ordinary signee so let's redirect to petition's page
      else
        redirect_to signed_petition_signature_path(@signature.petition) and return
      end
    else
      # We've found the signature, but it's already been verified.
      if @signature.state == Signature::VALIDATED_STATE
        flash[:notice] = "Thank you. Your signature has already been added to the <span class='nowrap'>e-petition</span>.".html_safe
        redirect_to signed_petition_signature_path(@signature.petition) and return
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  private
  def retrieve_petition
    @petition = Petition.visible.find(params[:petition_id])
  end

  def send_email_to_petition_signer(signature)
    PetitionMailer.email_confirmation_for_signer(signature).deliver
  end
end
