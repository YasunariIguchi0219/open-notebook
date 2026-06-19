import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import { resources } from './locales'

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: 'ja-JP',
    interpolation: {
      escapeValue: false, // react already safes from xss
    },
    react: {
      useSuspense: false,
    },
    detection: {
      // Default to Japanese (fallbackLng) when no saved preference exists.
      // Browser-language ('navigator') detection is intentionally omitted so the
      // app starts in Japanese; users can still switch and the choice persists.
      order: ['localStorage'],
      caches: ['localStorage'],
    },
  })

export default i18n
