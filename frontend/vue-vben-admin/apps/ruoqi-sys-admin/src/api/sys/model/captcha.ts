export interface CaptchaResp {
  captcha_token: string;
  captcha_image: string;
}

export interface GetEmailCaptchaReq {
  email: string;
}

export interface GetSmsCaptchaReq {
  phoneNumber: string;
}
