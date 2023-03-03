import Head from 'next/head'
import Image from 'next/image'
import styles from '@/styles/Home.module.css'
import Link from 'next/link'

export default function Home() {
  return (
    <div className={styles.container}>
      <Head>
        <title>Zicket</title>
        <meta name="description" content="Generated by zicket team" />
        <link rel="icon" href="/logoicon.ico" />
      </Head>
      <main className={styles.main}>
        <div className={styles.description}>
          <Image
            className={styles.logo}
            src="/blue_logo_new.svg"
            alt="Zicket Logo"
            width={118}
            height={118}
            priority
          />
          <div className={styles.contentInfo}>
            <p className={styles.title}>Welcome to Zicket!</p>
            <p className={styles.description}>
              In order to insure fair play and that evrybody can buy just one
              ticket <br /> we need to verify that you are human and prove you
              have not bought a ticket yet.
            </p>
          </div>
          <div>
            <Link href="/verification">
              <button className={styles.button}>
                Let{"'"}s start your verification
              </button>
            </Link>
          </div>
        </div>
      </main>
    </div>
  )
}
